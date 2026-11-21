# ==============================================================================
# CITY & PEDESTRIAN AUDIO GENERATOR
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Synthesizes procedural WAV sound effects for pedestrian shouts,
#          market ambient crowd murmur, and traffic crossing beeps.
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

def generate_vocal_exclamation(filepath, f0=220.0, duration=0.45):
    # Formant synthesized vocal exclamation (vowel 'Ah'/'Eh' formant filters at 700Hz and 1200Hz)
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        # Natural pitch dip over duration
        pitch = f0 * (1.15 - 0.3 * (t / duration))
        # Formants
        pulse = math.sin(2.0 * math.pi * pitch * t)
        formant1 = math.sin(2.0 * math.pi * 750.0 * t) * 0.4
        formant2 = math.sin(2.0 * math.pi * 1250.0 * t) * 0.3
        
        # Attack - Decay envelope
        env = 1.0
        if t < 0.04:
            env = t / 0.04
        elif t > duration - 0.1:
            env = (duration - t) / 0.1
        
        val = (pulse * 0.5 + formant1 + formant2) * env * 0.85
        samples.append(val)
    write_wav(filepath, samples)

def generate_market_chatter(filepath, duration=4.0):
    # Multi-layered ambient crowd murmur
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    # 5 independent low-frequency chatter oscillators
    voices = [130.0, 165.0, 195.0, 240.0, 280.0]
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        val = 0.0
        for v in voices:
            # Slight modulation
            mod = 1.0 + 0.1 * math.sin(2.0 * math.pi * 3.5 * t)
            val += math.sin(2.0 * math.pi * v * mod * t) * 0.15
        # Soft noise layer (footsteps, clothing, rustling)
        noise = (random.random() * 2.0 - 1.0) * 0.08
        val = (val + noise) * 0.7
        samples.append(val)
    # Loop crossfade
    fade_len = int(SAMPLE_RATE * 0.1)
    for i in range(fade_len):
        blend = i / fade_len
        samples[i] = samples[i] * blend + samples[num_samples - fade_len + i] * (1.0 - blend)
    write_wav(filepath, samples)

def generate_crossing_beep(filepath, duration=0.3):
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    freq = 1100.0
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        env = math.sin(math.pi * (t / duration))
        val = math.sin(2.0 * math.pi * freq * t) * env * 0.65
        samples.append(val)
    write_wav(filepath, samples)

def main():
    target_dir = r"audio/city"
    os.makedirs(target_dir, exist_ok=True)
    generate_vocal_exclamation(os.path.join(target_dir, "pedestrian_shout_1.wav"), f0=240.0)
    generate_vocal_exclamation(os.path.join(target_dir, "pedestrian_shout_2.wav"), f0=180.0)
    generate_market_chatter(os.path.join(target_dir, "market_chatter_loop.wav"), duration=4.0)
    generate_crossing_beep(os.path.join(target_dir, "crossing_beep.wav"), duration=0.25)

if __name__ == "__main__":
    main()
