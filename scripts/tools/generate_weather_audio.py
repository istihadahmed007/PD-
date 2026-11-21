# ==============================================================================
# WEATHER & ATMOSPHERIC AUDIO SYNTHESIS SCRIPT
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Synthesizes procedural WAV audio files for weather conditions:
#          - Heavy monsoon rainfall loop
#          - Thunder lightning strike 1 (sharp crack + rumble)
#          - Thunder lightning strike 2 (distant rolling boom)
#          - Storm wind gusts
# ==============================================================================
import os
import wave
import struct
import math
import random

SAMPLE_RATE = 44100

def create_wav(filepath, samples):
    os.makedirs(os.path.dirname(filepath), exist_ok=True)
    with wave.open(filepath, 'w') as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(SAMPLE_RATE)
        raw_data = bytearray()
        for s in samples:
            clamped = max(-1.0, min(1.0, s))
            int_val = int(clamped * 32767.0)
            raw_data.extend(struct.pack('<h', int_val))
        wav_file.writeframes(raw_data)
    print(f"Synthesized: {filepath} ({len(samples)} samples, {len(samples)/SAMPLE_RATE:.2f}s)")

def gen_rain_loop():
    # 3.0s loop: heavy rainfall hiss + droplets on tin roof
    duration = 3.0
    n_samples = int(duration * SAMPLE_RATE)
    samples = [0.0] * n_samples
    for i in range(n_samples):
        t = i / SAMPLE_RATE
        # Continuous rain noise
        noise = (random.random() * 2.0 - 1.0) * 0.35
        # Low rumble of water
        water_rumble = math.sin(2.0 * math.pi * 95.0 * t) * 0.15
        # Tin roof droplet clicks
        tin_drop = 0.0
        if random.random() < 0.02:
            tin_drop = (random.random() * 2.0 - 1.0) * 0.3
        samples[i] = noise + water_rumble + tin_drop
    return samples

def gen_thunder_1():
    # 2.5s: sharp electrical crack at t=0, followed by deep decaying low-frequency rumble
    duration = 2.5
    n_samples = int(duration * SAMPLE_RATE)
    samples = [0.0] * n_samples
    for i in range(n_samples):
        t = i / SAMPLE_RATE
        # Crack at t=0 to 0.15
        crack = 0.0
        if t < 0.15:
            crack = (random.random() * 2.0 - 1.0) * math.exp(-t * 20.0) * 0.8
        # Low frequency rumble (35 Hz to 70 Hz)
        rumble_env = math.exp(-t * 1.5)
        rumble = (math.sin(2.0 * math.pi * 42.0 * t) + math.sin(2.0 * math.pi * 58.0 * t) * 0.6) * rumble_env * 0.7
        samples[i] = crack + rumble
    return samples

def gen_thunder_2():
    # 3.0s: distant rolling booming thunder
    duration = 3.0
    n_samples = int(duration * SAMPLE_RATE)
    samples = [0.0] * n_samples
    for i in range(n_samples):
        t = i / SAMPLE_RATE
        env = math.sin(math.pi * (t / 3.0)) * math.exp(-t * 0.8)
        boom = math.sin(2.0 * math.pi * (38.0 + math.sin(t * 5.0) * 8.0) * t) * env * 0.75
        noise = (random.random() * 2.0 - 1.0) * env * 0.2
        samples[i] = boom + noise
    return samples

def gen_storm_wind():
    # 3.0s loop: whistling and surging storm wind
    duration = 3.0
    n_samples = int(duration * SAMPLE_RATE)
    samples = [0.0] * n_samples
    for i in range(n_samples):
        t = i / SAMPLE_RATE
        mod = math.sin(2.0 * math.pi * 0.5 * t) * 0.5 + 0.5 # 0 to 1
        noise = (random.random() * 2.0 - 1.0) * (0.2 + mod * 0.3)
        whistle = math.sin(2.0 * math.pi * (320.0 + mod * 180.0) * t) * 0.15
        samples[i] = noise + whistle
    return samples

def main():
    base_dir = "audio/weather"
    create_wav(os.path.join(base_dir, "rain_monsoon_loop.wav"), gen_rain_loop())
    create_wav(os.path.join(base_dir, "thunder_strike_1.wav"), gen_thunder_1())
    create_wav(os.path.join(base_dir, "thunder_strike_2.wav"), gen_thunder_2())
    create_wav(os.path.join(base_dir, "wind_storm.wav"), gen_storm_wind())
    print("\nAll Weather Audio Assets synthesized successfully!")

if __name__ == "__main__":
    main()
