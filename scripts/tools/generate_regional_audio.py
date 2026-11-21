# ==============================================================================
# REGIONAL AMBIENT AUDIO SYNTHESIS SCRIPT
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Synthesizes procedural ambient loops for the 7 geographical regions:
#          1. Dhaka: Urban traffic hum, distant horns, crows
#          2. Rajshahi & Padma: River water wash, wind over sandbars
#          3. Sylhet: Highland hill breeze, birdsong, morning crickets
#          4. Chattogram: Heavy container port hum, metal clangs, gulls
#          5. Cox's Bazar: Ocean surf, wave swell and wash
#          6. Sundarbans: Humid mangrove cicadas, tidal mud water lapping
#          7. Rural Agriculture: Countryside wind through paddy, village sparrows
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

def gen_dhaka_ambient():
    # 3.0s loop: low diesel rumble + distant honks + street hiss
    duration = 3.0
    n_samples = int(duration * SAMPLE_RATE)
    samples = [0.0] * n_samples
    for i in range(n_samples):
        t = i / SAMPLE_RATE
        rumble = math.sin(2.0 * math.pi * 55.0 * t) * 0.35 + math.sin(2.0 * math.pi * 110.0 * t) * 0.2
        noise = (random.random() * 2.0 - 1.0) * 0.15
        honk = 0.0
        if 0.8 <= t <= 1.2:
            ht = t - 0.8
            honk = math.sin(2.0 * math.pi * 480.0 * ht) * math.sin(math.pi * (ht / 0.4)) * 0.2
        samples[i] = (rumble + noise + honk) * 0.5
    return samples

def gen_padma_river_ambient():
    # 3.0s loop: gentle water lapping + breeze
    duration = 3.0
    n_samples = int(duration * SAMPLE_RATE)
    samples = [0.0] * n_samples
    for i in range(n_samples):
        t = i / SAMPLE_RATE
        wind = math.sin(2.0 * math.pi * 0.4 * t) * (random.random() * 2.0 - 1.0) * 0.2
        lap = math.sin(2.0 * math.pi * (180.0 + math.sin(t * 4.0) * 40.0) * t) * math.sin(math.pi * (t / 3.0)) * 0.25
        samples[i] = (wind + lap) * 0.45
    return samples

def gen_sylhet_hills_ambient():
    # 3.0s loop: high-altitude gentle breeze + rhythmic crickets
    duration = 3.0
    n_samples = int(duration * SAMPLE_RATE)
    samples = [0.0] * n_samples
    for i in range(n_samples):
        t = i / SAMPLE_RATE
        breeze = (random.random() * 2.0 - 1.0) * 0.12 * (0.8 + 0.2 * math.sin(t * 2.0))
        cricket = math.sin(2.0 * math.pi * 4500.0 * t) * (1.0 if (int(t * 12) % 2 == 0) else 0.0) * 0.15
        samples[i] = (breeze + cricket) * 0.4
    return samples

def gen_chattogram_port_ambient():
    # 3.0s loop: heavy industrial drone + resonant metal clang
    duration = 3.0
    n_samples = int(duration * SAMPLE_RATE)
    samples = [0.0] * n_samples
    for i in range(n_samples):
        t = i / SAMPLE_RATE
        drone = math.sin(2.0 * math.pi * 42.0 * t) * 0.4 + math.sin(2.0 * math.pi * 84.0 * t) * 0.25
        clang = 0.0
        if 1.4 <= t <= 2.2:
            ct = t - 1.4
            env = math.exp(-ct * 5.0)
            clang = (math.sin(2.0 * math.pi * 620.0 * ct) + math.sin(2.0 * math.pi * 1420.0 * ct) * 0.4) * env * 0.35
        samples[i] = (drone + clang + (random.random() * 0.1)) * 0.5
    return samples

def gen_cox_ocean_ambient():
    # 3.0s loop: continuous sea wave wash
    duration = 3.0
    n_samples = int(duration * SAMPLE_RATE)
    samples = [0.0] * n_samples
    for i in range(n_samples):
        t = i / SAMPLE_RATE
        swell = math.sin(math.pi * (t / 3.0)) # 0 to 1 back to 0
        surf = (random.random() * 2.0 - 1.0) * swell * 0.45
        low_roar = math.sin(2.0 * math.pi * 65.0 * t) * swell * 0.3
        samples[i] = (surf + low_roar) * 0.55
    return samples

def gen_sundarbans_ambient():
    # 3.0s loop: dense tropical cicadas and murky water ripples
    duration = 3.0
    n_samples = int(duration * SAMPLE_RATE)
    samples = [0.0] * n_samples
    for i in range(n_samples):
        t = i / SAMPLE_RATE
        cicada1 = math.sin(2.0 * math.pi * 3200.0 * t) * (math.sin(t * 18.0) * 0.5 + 0.5) * 0.2
        cicada2 = math.sin(2.0 * math.pi * 5200.0 * t) * (math.sin(t * 24.0) * 0.5 + 0.5) * 0.15
        water = math.sin(2.0 * math.pi * 210.0 * t) * math.exp(-((t % 0.8) * 6.0)) * 0.2
        samples[i] = (cicada1 + cicada2 + water) * 0.45
    return samples

def gen_rural_ambient():
    # 3.0s loop: peaceful open field breeze and rustling vegetation
    duration = 3.0
    n_samples = int(duration * SAMPLE_RATE)
    samples = [0.0] * n_samples
    for i in range(n_samples):
        t = i / SAMPLE_RATE
        rustle = (random.random() * 2.0 - 1.0) * (0.15 + 0.08 * math.sin(t * 3.5))
        bird = 0.0
        if 0.5 <= t <= 0.8 or 2.1 <= t <= 2.4:
            bt = t if t <= 0.8 else (t - 1.6)
            bird = math.sin(2.0 * math.pi * (2400.0 + bt * 1200.0) * bt) * 0.18
        samples[i] = (rustle + bird) * 0.45
    return samples

def main():
    base_dir = "audio/ambient"
    create_wav(os.path.join(base_dir, "ambient_dhaka_city.wav"), gen_dhaka_ambient())
    create_wav(os.path.join(base_dir, "ambient_padma_river.wav"), gen_padma_river_ambient())
    create_wav(os.path.join(base_dir, "ambient_sylhet_hills.wav"), gen_sylhet_hills_ambient())
    create_wav(os.path.join(base_dir, "ambient_chattogram_port.wav"), gen_chattogram_port_ambient())
    create_wav(os.path.join(base_dir, "ambient_cox_ocean.wav"), gen_cox_ocean_ambient())
    create_wav(os.path.join(base_dir, "ambient_sundarbans_jungle.wav"), gen_sundarbans_ambient())
    create_wav(os.path.join(base_dir, "ambient_rural_fields.wav"), gen_rural_ambient())
    print("\nAll 7 Regional Ambient Audio loops generated successfully!")

if __name__ == "__main__":
    main()
