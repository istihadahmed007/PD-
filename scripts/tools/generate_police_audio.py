# ==============================================================================
# POLICE AUDIO GENERATOR
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Synthesizes procedural PCM WAV sound effects for police sirens (wail & yelp),
#          police radio squelch/dispatch, traffic police whistle, bullhorn,
#          handcuff arrest, and spike strip puncture.
# ==============================================================================
import os
import wave
import struct
import math
import random

SAMPLE_RATE = 44100

def write_wav(filepath, samples):
    os.makedirs(os.path.dirname(filepath), exist_ok=True)
    with wave.open(filepath, "w") as wav_file:
        wav_file.setnchannels(1)      # Mono
        wav_file.setsampwidth(2)      # 16-bit
        wav_file.setframerate(SAMPLE_RATE)
        raw_data = bytearray()
        for s in samples:
            val = max(-1.0, min(1.0, s))
            int_val = int(val * 32767.0)
            raw_data.extend(struct.pack("<h", int_val))
        wav_file.writeframes(raw_data)
    print(f"Generated: {filepath} ({len(samples)/SAMPLE_RATE:.2f}s)")

def generate_siren_wail(filepath, duration=4.0):
    # Classic slow rising and falling dual-tone wail siren (600 Hz to 1200 Hz cycle over 3.2s)
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    cycle_period = 3.2
    phase = 0.0
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        # Sine modulation between 650Hz and 1150Hz
        mod = 0.5 * (1.0 + math.sin(2.0 * math.pi * (1.0 / cycle_period) * t - math.pi / 2.0))
        freq = 650.0 + mod * 550.0
        phase += 2.0 * math.pi * freq / SAMPLE_RATE
        
        # Primary tone with strong 2nd and 3rd harmonics for sharp siren piercing tone
        val = (
            0.65 * math.sin(phase) +
            0.30 * math.sin(phase * 2.0) +
            0.15 * math.sin(phase * 3.0)
        )
        # Soft saturation
        val = math.tanh(val * 1.2) * 0.85
        samples.append(val)
        
    # Crossfade loop endpoints
    fade_len = int(SAMPLE_RATE * 0.1)
    for i in range(fade_len):
        blend = i / fade_len
        samples[i] = samples[i] * blend + samples[num_samples - fade_len + i] * (1.0 - blend)
    write_wav(filepath, samples)

def generate_siren_yelp(filepath, duration=2.0):
    # Rapid cycling pursuit yelp siren (700 Hz to 1350 Hz cycling every 0.28 seconds)
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    cycle_period = 0.28
    phase = 0.0
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        # Fast sawtooth/sine modulation
        mod = (t % cycle_period) / cycle_period
        freq = 720.0 + mod * 680.0
        phase += 2.0 * math.pi * freq / SAMPLE_RATE
        
        val = (
            0.70 * math.sin(phase) +
            0.25 * math.sin(phase * 2.0) +
            0.12 * math.sin(phase * 3.0)
        )
        val = math.tanh(val * 1.3) * 0.85
        samples.append(val)
        
    fade_len = int(SAMPLE_RATE * 0.05)
    for i in range(fade_len):
        blend = i / fade_len
        samples[i] = samples[i] * blend + samples[num_samples - fade_len + i] * (1.0 - blend)
    write_wav(filepath, samples)

def generate_police_radio(filepath, duration=1.2):
    # Radio mic click, burst of bandpass static noise and two short squelch tones
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        val = 0.0
        # Opening mic pop
        if t < 0.08:
            val += math.sin(2.0 * math.pi * 120.0 * t) * (1.0 - t / 0.08) * 0.6
        # Radio squelch / static hiss
        noise = (random.random() * 2.0 - 1.0) * 0.25
        # Modulated tone beep (dispatch tone burst at 850 Hz and 1100 Hz)
        if 0.08 <= t < 0.22:
            tone = math.sin(2.0 * math.pi * 880.0 * t) * 0.4
            val += tone + noise * 0.3
        elif 0.25 <= t < 0.40:
            tone = math.sin(2.0 * math.pi * 1150.0 * t) * 0.4
            val += tone + noise * 0.3
        elif 0.40 <= t < 0.95:
            # Low hum and muffled transmission chatter noise
            val += noise * 0.35 + math.sin(2.0 * math.pi * 320.0 * t) * 0.08
        else:
            # Closing mic click
            val += (random.random() * 2.0 - 1.0) * math.exp(-(t - 0.95) * 40.0) * 0.5
        samples.append(val * 0.8)
    write_wav(filepath, samples)

def generate_police_whistle(filepath, duration=0.8):
    # Traffic police metal pea whistle: high-pitched 2800 Hz shrill tone with 25 Hz pea warble
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        envelope = min(1.0, t / 0.03) * max(0.0, 1.0 - t / duration)
        # Pea warble
        warble = 1.0 + 0.18 * math.sin(2.0 * math.pi * 26.0 * t)
        freq = 2850.0 * warble
        tone = (
            0.6 * math.sin(2.0 * math.pi * freq * t) +
            0.3 * math.sin(2.0 * math.pi * (freq * 1.05) * t) + # Dissonant beating
            0.15 * (random.random() * 2.0 - 1.0) # Breath air noise
        )
        samples.append(tone * envelope * 0.75)
    write_wav(filepath, samples)

def generate_handcuff_click(filepath, duration=0.6):
    # Metallic ratchet clicks followed by snap closure
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        val = 0.0
        # 3 ratchet clicks at 0.1s, 0.22s, 0.34s
        for click_t in [0.08, 0.18, 0.28]:
            dt = t - click_t
            if 0 <= dt < 0.03:
                decay = math.exp(-dt * 300.0)
                click = math.sin(2.0 * math.pi * 3400.0 * dt) * decay
                val += click * 0.4
        # Solid latch snap at 0.42s
        dt_snap = t - 0.42
        if 0 <= dt_snap < 0.15:
            decay = math.exp(-dt_snap * 80.0)
            snap = (
                0.7 * math.sin(2.0 * math.pi * 1800.0 * dt_snap) +
                0.3 * math.sin(2.0 * math.pi * 850.0 * dt_snap) +
                0.3 * (random.random() * 2.0 - 1.0)
            ) * decay
            val += snap * 0.85
        samples.append(val)
    write_wav(filepath, samples)

def generate_spike_puncture(filepath, duration=1.0):
    # High pressure blowout hiss and metallic tire crunch
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        # Initial spike impact pop
        val = 0.0
        if t < 0.05:
            val += (random.random() * 2.0 - 1.0) * math.exp(-t * 120.0) * 0.8
        # High pressure air hiss escaping
        if t >= 0.02:
            decay = math.exp(-(t - 0.02) * 4.5)
            hiss = (random.random() * 2.0 - 1.0) * decay * 0.65
            # Low tire rumble
            rumble = math.sin(2.0 * math.pi * 75.0 * t) * decay * 0.25
            val += hiss + rumble
        samples.append(val)
    write_wav(filepath, samples)

if __name__ == "__main__":
    out_dir = os.path.join("audio", "police")
    os.makedirs(out_dir, exist_ok=True)
    generate_siren_wail(os.path.join(out_dir, "siren_wail.wav"))
    generate_siren_yelp(os.path.join(out_dir, "siren_yelp.wav"))
    generate_police_radio(os.path.join(out_dir, "police_radio.wav"))
    generate_police_whistle(os.path.join(out_dir, "police_whistle.wav"))
    generate_handcuff_click(os.path.join(out_dir, "handcuff_click.wav"))
    generate_spike_puncture(os.path.join(out_dir, "spike_puncture.wav"))
    print("All police audio assets successfully generated!")
