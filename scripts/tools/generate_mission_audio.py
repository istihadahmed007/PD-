# ==============================================================================
# MISSION AUDIO GENERATOR
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Synthesizes procedural PCM WAV sound effects for mission events:
#          - Mission started fanfare / brass chime
#          - Objective update jingle
#          - Checkpoint reached chime
#          - Mission completed triumphant melody
#          - Mission failed somber chord
#          - Character dialogue voice blip / radio squelch
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

def generate_mission_started(filepath, duration=1.2):
    # Rising brass fanfare (Notes: C4, G4, C5 arpeggio with rich harmonics)
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    notes = [
        (0.0, 0.25, 261.63), # C4
        (0.2, 0.50, 392.00), # G4
        (0.45, 1.20, 523.25) # C5
    ]
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        val = 0.0
        for start, end, freq in notes:
            if start <= t < end:
                dt = t - start
                env = min(1.0, dt / 0.04) * math.exp(-dt * 3.5)
                # Brass harmonics
                tone = (
                    0.6 * math.sin(2.0 * math.pi * freq * dt) +
                    0.3 * math.sin(2.0 * math.pi * freq * 2 * dt) +
                    0.15 * math.sin(2.0 * math.pi * freq * 3 * dt)
                )
                val += tone * env
        samples.append(val * 0.85)
    write_wav(filepath, samples)

def generate_objective_update(filepath, duration=0.6):
    # Crisp high chime (Dual bell tone: 880 Hz to 1320 Hz)
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        val = 0.0
        # Bell 1 at 0s (880 Hz)
        if t < 0.4:
            decay1 = math.exp(-t * 12.0)
            val += 0.5 * math.sin(2.0 * math.pi * 880.0 * t) * decay1
        # Bell 2 at 0.12s (1320 Hz)
        if t >= 0.12:
            dt = t - 0.12
            decay2 = math.exp(-dt * 9.0)
            val += 0.6 * math.sin(2.0 * math.pi * 1320.0 * dt) * decay2
        samples.append(val)
    write_wav(filepath, samples)

def generate_checkpoint_reached(filepath, duration=0.5):
    # Soft positive electronic pulse (523 Hz to 659 Hz slide)
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 6.0)
        freq = 523.0 + (t / duration) * 136.0
        val = 0.7 * math.sin(2.0 * math.pi * freq * t) * env
        samples.append(val)
    write_wav(filepath, samples)

def generate_mission_completed(filepath, duration=2.5):
    # Triumphant multi-chord resolution (Bengali victory motif: C major to F to G to C octaves)
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    chords = [
        # start, duration, [frequencies]
        (0.00, 0.45, [261.63, 329.63, 392.00]),       # C major
        (0.40, 0.45, [349.23, 440.00, 523.25]),       # F major
        (0.80, 0.55, [392.00, 493.88, 587.33]),       # G major
        (1.30, 1.20, [523.25, 659.25, 783.99, 1046.50]) # C major grand finale
    ]
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        val = 0.0
        for start, dur, freqs in chords:
            if start <= t < start + dur:
                dt = t - start
                env = min(1.0, dt / 0.03) * math.exp(-dt * 2.2)
                chord_val = 0.0
                for f in freqs:
                    chord_val += math.sin(2.0 * math.pi * f * dt) * (0.8 / len(freqs))
                val += chord_val * env
        samples.append(val * 0.9)
    write_wav(filepath, samples)

def generate_mission_failed(filepath, duration=2.0):
    # Somber minor chords with low brass dissonance (C minor falling to A-flat)
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    chords = [
        (0.0, 0.8, [261.63, 311.13, 392.00]), # C minor
        (0.7, 1.3, [207.65, 261.63, 311.13])  # Ab major / C minor dissonance
    ]
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        val = 0.0
        for start, dur, freqs in chords:
            if start <= t < start + dur:
                dt = t - start
                env = min(1.0, dt / 0.05) * math.exp(-dt * 1.8)
                for f in freqs:
                    val += math.sin(2.0 * math.pi * f * dt) * 0.25 * env
        # Low cello drone
        val += 0.25 * math.sin(2.0 * math.pi * 65.4 * t) * math.exp(-t * 1.5)
        samples.append(val)
    write_wav(filepath, samples)

def generate_dialogue_blip(filepath, duration=0.08):
    # Short friendly dialogue text blip (radio tick at 720 Hz)
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 50.0)
        val = 0.5 * math.sin(2.0 * math.pi * 740.0 * t) * env
        samples.append(val)
    write_wav(filepath, samples)

if __name__ == "__main__":
    out_dir = os.path.join("audio", "missions")
    os.makedirs(out_dir, exist_ok=True)
    generate_mission_started(os.path.join(out_dir, "mission_started.wav"))
    generate_objective_update(os.path.join(out_dir, "objective_updated.wav"))
    generate_checkpoint_reached(os.path.join(out_dir, "checkpoint_reached.wav"))
    generate_mission_completed(os.path.join(out_dir, "mission_completed.wav"))
    generate_mission_failed(os.path.join(out_dir, "mission_failed.wav"))
    generate_dialogue_blip(os.path.join(out_dir, "dialogue_blip.wav"))
    print("All mission audio assets successfully synthesized!")
