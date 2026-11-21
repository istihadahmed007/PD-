# ==============================================================================
# VEHICLE AUDIO GENERATOR
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Synthesizes high-fidelity procedural PCM WAV sound effects for engines,
#          horns, air brakes, doors, and tire skids using standard library.
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
        # Convert float (-1.0 to 1.0) to 16-bit signed int
        raw_data = bytearray()
        for s in samples:
            val = max(-1.0, min(1.0, s))
            int_val = int(val * 32767.0)
            raw_data.extend(struct.pack("<h", int_val))
        wav_file.writeframes(raw_data)
    print(f"Generated: {filepath} ({len(samples)/SAMPLE_RATE:.2f}s)")

def generate_engine_loop(filepath, base_freq=65.0, duration=2.0, harmonics=(1.0, 0.7, 0.4, 0.25), distortion=0.15):
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    phase = 0.0
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        val = 0.0
        for h_idx, amp in enumerate(harmonics, start=1):
            val += amp * math.sin(2.0 * math.pi * base_freq * h_idx * t)
        # Add slight cylinder firing irregularity / pulse
        pulse = math.sin(2.0 * math.pi * (base_freq * 0.5) * t)
        val = val * (0.85 + 0.15 * pulse)
        # Soft clipping saturation
        val = math.tanh(val * (1.0 + distortion)) * 0.75
        samples.append(val)
    # Ensure smooth loop endpoints with crossfade
    fade_len = int(SAMPLE_RATE * 0.05)
    for i in range(fade_len):
        blend = i / fade_len
        samples[i] = samples[i] * blend + samples[num_samples - fade_len + i] * (1.0 - blend)
    write_wav(filepath, samples)

def generate_cng_loop(filepath, duration=2.0):
    # Iconic Dhaka CNG Baby Taxi: snappy 2-stroke buzzy rhythm (higher fundamental, sharper harmonics)
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    base_freq = 92.0
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        # Rich odd/even harmonics for tinny 2-stroke buzz
        val = (
            0.6 * math.sin(2.0 * math.pi * base_freq * t) +
            0.5 * math.sin(2.0 * math.pi * base_freq * 2 * t) +
            0.4 * math.sin(2.0 * math.pi * base_freq * 3 * t) +
            0.35 * math.sin(2.0 * math.pi * base_freq * 4 * t) +
            0.25 * math.sin(2.0 * math.pi * base_freq * 5 * t)
        )
        # Rapid stroke pop
        stroke = 1.0 + 0.3 * math.sin(2.0 * math.pi * (base_freq / 2.0) * t)
        val *= stroke
        # Slight rasp noise
        rasp = (random.random() * 2.0 - 1.0) * 0.08
        val = math.tanh((val + rasp) * 1.4) * 0.7
        samples.append(val)
    fade_len = int(SAMPLE_RATE * 0.05)
    for i in range(fade_len):
        blend = i / fade_len
        samples[i] = samples[i] * blend + samples[num_samples - fade_len + i] * (1.0 - blend)
    write_wav(filepath, samples)

def generate_bus_diesel_loop(filepath, duration=2.5):
    # Heavy Dhaka City Bus: Low, deep 42Hz diesel thrum with turbo hiss
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    base_freq = 42.0
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        val = (
            0.8 * math.sin(2.0 * math.pi * base_freq * t) +
            0.6 * math.sin(2.0 * math.pi * base_freq * 2 * t) +
            0.4 * math.sin(2.0 * math.pi * base_freq * 3 * t) +
            0.3 * math.sin(2.0 * math.pi * base_freq * 4 * t)
        )
        compression = 1.0 + 0.35 * math.cos(2.0 * math.pi * (base_freq * 0.25) * t)
        val *= compression
        # Turbo whistle
        turbo = 0.05 * math.sin(2.0 * math.pi * 1450.0 * t)
        val = math.tanh((val + turbo) * 1.2) * 0.85
        samples.append(val)
    fade_len = int(SAMPLE_RATE * 0.05)
    for i in range(fade_len):
        blend = i / fade_len
        samples[i] = samples[i] * blend + samples[num_samples - fade_len + i] * (1.0 - blend)
    write_wav(filepath, samples)

def generate_dual_horn(filepath, f1, f2, duration=0.45):
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        # Envelope: quick attack, sustained, fast decay
        env = 1.0
        if t < 0.02:
            env = t / 0.02
        elif t > duration - 0.05:
            env = (duration - t) / 0.05
        val = (math.sin(2.0 * math.pi * f1 * t) + math.sin(2.0 * math.pi * f2 * t)) * 0.5 * env
        samples.append(val * 0.85)
    write_wav(filepath, samples)

def generate_door_open(filepath):
    # Metal handle unlatch click followed by hinge groan
    duration = 0.35
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        val = 0.0
        if t < 0.06:
            # Mechanical latch click
            val = math.sin(2.0 * math.pi * 850.0 * t) * math.exp(-t * 60.0)
            val += (random.random() * 2.0 - 1.0) * 0.3 * math.exp(-t * 80.0)
        else:
            # Subtle low hinge movement
            ht = t - 0.06
            val = math.sin(2.0 * math.pi * 120.0 * ht) * math.exp(-ht * 15.0) * 0.25
        samples.append(val * 0.8)
    write_wav(filepath, samples)

def generate_door_close(filepath):
    # Solid heavy door thud & seal latch
    duration = 0.32
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        val = 0.0
        # Heavy low thud
        thud = math.sin(2.0 * math.pi * 75.0 * t) * math.exp(-t * 22.0)
        # Metal latch bite
        latch = math.sin(2.0 * math.pi * 920.0 * t) * math.exp(-t * 45.0) * 0.4
        noise = (random.random() * 2.0 - 1.0) * math.exp(-t * 35.0) * 0.25
        val = (thud + latch + noise) * 0.9
        samples.append(val)
    write_wav(filepath, samples)

def generate_skid(filepath):
    # High-pitched tire rubber asphalt screech
    duration = 0.8
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        env = math.sin(math.pi * (t / duration)) # Arch envelope
        # Filtered white noise with dual resonant peaks (800Hz & 1400Hz)
        noise = random.random() * 2.0 - 1.0
        res1 = math.sin(2.0 * math.pi * 820.0 * t) * 0.4
        res2 = math.sin(2.0 * math.pi * 1380.0 * t) * 0.3
        val = (noise * 0.5 + res1 + res2) * env * 0.65
        samples.append(val)
    write_wav(filepath, samples)

def generate_impact(filepath):
    # Heavy metallic impact and deformation crunch
    duration = 0.6
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        # Low frequency chassis shock
        low = math.sin(2.0 * math.pi * 55.0 * t) * math.exp(-t * 12.0)
        # Metal panel crunch
        crunch = (random.random() * 2.0 - 1.0) * math.exp(-t * 18.0) * 0.8
        # High resonance ping
        ping = math.sin(2.0 * math.pi * 1150.0 * t) * math.exp(-t * 30.0) * 0.35
        val = (low + crunch + ping) * 0.95
        samples.append(val)
    write_wav(filepath, samples)

def main():
    target_dir = r"audio/vehicles"
    os.makedirs(target_dir, exist_ok=True)
    
    # Engines
    generate_engine_loop(os.path.join(target_dir, "engine_sedan_loop.wav"), base_freq=65.0, duration=2.0)
    generate_engine_loop(os.path.join(target_dir, "engine_suv_loop.wav"), base_freq=50.0, duration=2.0, harmonics=(1.0, 0.8, 0.5, 0.3))
    generate_engine_loop(os.path.join(target_dir, "engine_bike_loop.wav"), base_freq=85.0, duration=2.0, harmonics=(0.9, 0.7, 0.5, 0.4))
    generate_cng_loop(os.path.join(target_dir, "engine_cng_loop.wav"), duration=2.0)
    generate_bus_diesel_loop(os.path.join(target_dir, "engine_bus_loop.wav"), duration=2.5)

    # Horns
    generate_dual_horn(os.path.join(target_dir, "horn_sedan.wav"), 440.0, 554.0, duration=0.4)
    generate_dual_horn(os.path.join(target_dir, "horn_suv.wav"), 370.0, 466.0, duration=0.45)
    generate_dual_horn(os.path.join(target_dir, "horn_bus_air.wav"), 311.0, 392.0, duration=0.7)
    generate_dual_horn(os.path.join(target_dir, "horn_cng.wav"), 680.0, 810.0, duration=0.35)
    generate_dual_horn(os.path.join(target_dir, "horn_bike.wav"), 520.0, 620.0, duration=0.3)

    # Mechanics & SFX
    generate_door_open(os.path.join(target_dir, "car_door_open.wav"))
    generate_door_close(os.path.join(target_dir, "car_door_close.wav"))
    generate_skid(os.path.join(target_dir, "tire_skid.wav"))
    generate_impact(os.path.join(target_dir, "vehicle_impact.wav"))

if __name__ == "__main__":
    main()
