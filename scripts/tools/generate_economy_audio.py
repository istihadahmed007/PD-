# ==============================================================================
# ECONOMY AUDIO SYNTHESIS SCRIPT
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Synthesizes procedural WAV audio files for economy & interaction:
#          - Cash register ding & drawer
#          - Coin drop / jingle
#          - ATM electronic beep
#          - Item pickup pop
#          - Item drop thud
#          - Food crunch / drink slurp
#          - Mechanic wrench / ratchet
#          - Clothing equip swish
#          - Safehouse heavy door lock
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
        wav_file.setnchannels(1)        # Mono
        wav_file.setsampwidth(2)        # 16-bit
        wav_file.setframerate(SAMPLE_RATE)
        
        # Clamp & pack
        raw_data = bytearray()
        for s in samples:
            clamped = max(-1.0, min(1.0, s))
            int_val = int(clamped * 32767.0)
            raw_data.extend(struct.pack('<h', int_val))
        wav_file.writeframes(raw_data)
    print(f"Synthesized: {filepath} ({len(samples)} samples, {len(samples)/SAMPLE_RATE:.2f}s)")

def gen_cash_register():
    # 0.65s: metallic bell strike followed by rolling drawer click and coin rattle
    duration = 0.65
    n_samples = int(duration * SAMPLE_RATE)
    samples = [0.0] * n_samples
    
    # 1. Bell strike at t=0 (High frequency pure chime)
    bell_freq = 2800.0
    for i in range(n_samples):
        t = i / SAMPLE_RATE
        # High chime decaying
        env_bell = math.exp(-t * 9.0)
        chime = math.sin(2.0 * math.pi * bell_freq * t) + 0.4 * math.sin(2.0 * math.pi * (bell_freq * 1.5) * t)
        
        # 2. Drawer slide / mechanical ratchet at t=0.08 to 0.35
        drawer = 0.0
        if 0.08 <= t <= 0.45:
            dt = t - 0.08
            noise = (random.random() * 2.0 - 1.0) * math.exp(-dt * 6.0)
            ratchet = math.sin(2.0 * math.pi * 140.0 * dt) * (1.0 if (int(dt * 60) % 2 == 0) else -1.0)
            drawer = (noise * 0.35 + ratchet * 0.25)
            
        # 3. Coins settling at t=0.25 to 0.60
        coins = 0.0
        if 0.22 <= t <= 0.62:
            ct = t - 0.22
            c_freq = 3200.0 + math.sin(ct * 40.0) * 800.0
            coins = math.sin(2.0 * math.pi * c_freq * ct) * math.exp(-ct * 8.0) * 0.35
            if random.random() < 0.15:
                coins += (random.random() * 2.0 - 1.0) * 0.3
                
        samples[i] = (chime * env_bell * 0.55) + drawer + coins
        
    return samples

def gen_coin_drop():
    # 0.4s: metallic ping with short bouncing jingles
    duration = 0.4
    n_samples = int(duration * SAMPLE_RATE)
    samples = [0.0] * n_samples
    
    # Bounces at t=0, t=0.1, t=0.18, t=0.25
    bounces = [
        (0.00, 2400.0, 0.7),
        (0.09, 2900.0, 0.5),
        (0.17, 3300.0, 0.35),
        (0.24, 3800.0, 0.2),
        (0.29, 4200.0, 0.12),
    ]
    
    for t_start, freq, amp in bounces:
        idx_start = int(t_start * SAMPLE_RATE)
        for i in range(idx_start, n_samples):
            t = (i - idx_start) / SAMPLE_RATE
            env = math.exp(-t * 28.0)
            val = math.sin(2.0 * math.pi * freq * t) * env * amp
            samples[i] += val
            
    return samples

def gen_atm_beep():
    # 0.12s: clean electronic dual-tone ATM UI beep
    duration = 0.12
    n_samples = int(duration * SAMPLE_RATE)
    samples = [0.0] * n_samples
    
    freq1 = 1760.0 # A6
    freq2 = 2640.0 # E7
    
    for i in range(n_samples):
        t = i / SAMPLE_RATE
        env = math.sin(math.pi * (i / n_samples)) # Smooth Hann envelope
        val = (math.sin(2.0 * math.pi * freq1 * t) * 0.6 + math.sin(2.0 * math.pi * freq2 * t) * 0.4) * env
        samples[i] = val * 0.5
        
    return samples

def gen_item_pickup():
    # 0.18s: crisp ascending arpeggio blip / pop
    duration = 0.18
    n_samples = int(duration * SAMPLE_RATE)
    samples = [0.0] * n_samples
    
    for i in range(n_samples):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 14.0)
        freq = 880.0 + t * 4500.0 # Pitch slide up
        val = math.sin(2.0 * math.pi * freq * t) * env * 0.55
        samples[i] = val
        
    return samples

def gen_item_drop():
    # 0.15s: soft low thud / tap
    duration = 0.15
    n_samples = int(duration * SAMPLE_RATE)
    samples = [0.0] * n_samples
    
    for i in range(n_samples):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 24.0)
        freq = 180.0 * math.exp(-t * 15.0)
        val = math.sin(2.0 * math.pi * freq * t) * env * 0.6
        samples[i] = val
        
    return samples

def gen_eat_drink():
    # 0.35s: crunch / gulp consumable sound
    duration = 0.35
    n_samples = int(duration * SAMPLE_RATE)
    samples = [0.0] * n_samples
    
    for i in range(n_samples):
        t = i / SAMPLE_RATE
        env = math.sin(math.pi * (i / n_samples))
        # Mix filtered noise and resonant bubble tone
        noise = (random.random() * 2.0 - 1.0) * math.exp(-t * 10.0)
        bubble = math.sin(2.0 * math.pi * (320.0 + math.sin(t * 30.0) * 150.0) * t) * 0.35
        samples[i] = (noise * 0.4 + bubble) * env * 0.6
        
    return samples

def gen_wrench_ratchet():
    # 0.45s: metallic ratchet clicks (4 clicks)
    duration = 0.45
    n_samples = int(duration * SAMPLE_RATE)
    samples = [0.0] * n_samples
    
    clicks = [0.02, 0.12, 0.22, 0.32]
    for c_t in clicks:
        idx_start = int(c_t * SAMPLE_RATE)
        for i in range(idx_start, min(idx_start + int(0.06 * SAMPLE_RATE), n_samples)):
            t = (i - idx_start) / SAMPLE_RATE
            env = math.exp(-t * 70.0)
            metallic = math.sin(2.0 * math.pi * 1850.0 * t) + math.sin(2.0 * math.pi * 3200.0 * t) * 0.5
            noise = (random.random() * 2.0 - 1.0) * 0.4
            samples[i] += (metallic + noise) * env * 0.45
            
    return samples

def gen_cloth_equip():
    # 0.25s: soft fabric swish
    duration = 0.25
    n_samples = int(duration * SAMPLE_RATE)
    samples = [0.0] * n_samples
    
    for i in range(n_samples):
        t = i / SAMPLE_RATE
        env = math.sin(math.pi * (i / n_samples))
        noise = (random.random() * 2.0 - 1.0)
        samples[i] = noise * env * 0.35
        
    return samples

def gen_door_unlock():
    # 0.55s: heavy key turn and deadbolt clunk
    duration = 0.55
    n_samples = int(duration * SAMPLE_RATE)
    samples = [0.0] * n_samples
    
    # 1. Key turn at t=0.05
    for i in range(int(0.05 * SAMPLE_RATE), int(0.20 * SAMPLE_RATE)):
        t = (i - 0.05 * SAMPLE_RATE) / SAMPLE_RATE
        env = math.exp(-t * 30.0)
        samples[i] += math.sin(2.0 * math.pi * 2100.0 * t) * env * 0.35
        
    # 2. Heavy deadbolt clunk at t=0.25
    idx_clunk = int(0.25 * SAMPLE_RATE)
    for i in range(idx_clunk, n_samples):
        t = (i - idx_clunk) / SAMPLE_RATE
        env = math.exp(-t * 18.0)
        thud = math.sin(2.0 * math.pi * 85.0 * t) * 0.7
        metallic = math.sin(2.0 * math.pi * 750.0 * t) * 0.4
        samples[i] += (thud + metallic) * env * 0.65
        
    return samples

def main():
    base_dir = "audio/economy"
    create_wav(os.path.join(base_dir, "cash_register.wav"), gen_cash_register())
    create_wav(os.path.join(base_dir, "coin_drop.wav"), gen_coin_drop())
    create_wav(os.path.join(base_dir, "atm_beep.wav"), gen_atm_beep())
    create_wav(os.path.join(base_dir, "item_pickup.wav"), gen_item_pickup())
    create_wav(os.path.join(base_dir, "item_drop.wav"), gen_item_drop())
    create_wav(os.path.join(base_dir, "eat_drink.wav"), gen_eat_drink())
    create_wav(os.path.join(base_dir, "wrench_ratchet.wav"), gen_wrench_ratchet())
    create_wav(os.path.join(base_dir, "cloth_equip.wav"), gen_cloth_equip())
    create_wav(os.path.join(base_dir, "door_unlock.wav"), gen_door_unlock())
    print("\nAll Economy Audio Assets generated successfully!")

if __name__ == "__main__":
    main()
