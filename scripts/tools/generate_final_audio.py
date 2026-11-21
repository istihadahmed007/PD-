# ==============================================================================
# AUDIO GENERATION SUITE FOR PART 10 (FINAL GAME SYSTEMS & WINDOWS RELEASE)
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Procedurally synthesizes high-quality 44.1kHz 16-bit WAV assets:
#          - Player footsteps (asphalt 1-4, puddle splashes 1-2, jump, land)
#          - Authentic Bengali NPC voice callouts (bengali_callout_1 to 4)
#          - Original soundtrack & radio tracks (main theme, radio rock, hip-hop, folk)
# ==============================================================================
import os
import wave
import struct
import math
import random

SAMPLE_RATE = 44100

def create_wav_file(filename, samples, sample_rate=SAMPLE_RATE, channels=1):
    os.makedirs(os.path.dirname(filename), exist_ok=True)
    with wave.open(filename, 'w') as wf:
        wf.setnchannels(channels)
        wf.setsampwidth(2) # 16-bit
        wf.setframerate(sample_rate)
        
        packed_data = bytearray()
        for s in samples:
            # Clamp between -1.0 and 1.0
            val = max(-1.0, min(1.0, s))
            int_val = int(val * 32767.0)
            packed_data.extend(struct.pack('<h', int_val))
            
        wf.writeframes(packed_data)
    print(f"Generated {filename} ({len(samples)} frames, {len(samples)/sample_rate:.2f}s)")

# ------------------------------------------------------------------------------
# 1. PLAYER FOOTSTEPS & MOVEMENT AUDIO
# ------------------------------------------------------------------------------
def generate_footsteps():
    # 4 Asphalt footsteps (short tap with damped high frequencies)
    for i in range(1, 5):
        duration = 0.18
        num_samples = int(SAMPLE_RATE * duration)
        samples = []
        base_freq = 110.0 + (i * 12.0)
        
        for n in range(num_samples):
            t = n / SAMPLE_RATE
            env = math.exp(-t * 32.0)
            # Thump tone + friction grit noise
            thump = math.sin(2.0 * math.pi * base_freq * (1.0 - t * 4.0) * t) * 0.65
            noise = (random.random() * 2.0 - 1.0) * 0.35 * (1.0 - t * 6.0) if t < 0.15 else 0.0
            samples.append((thump + noise) * env * 0.8)
            
        create_wav_file(f"audio/player/footstep_asphalt_{i}.wav", samples)

    # 2 Water puddle splash footsteps
    for i in range(1, 3):
        duration = 0.28
        num_samples = int(SAMPLE_RATE * duration)
        samples = []
        
        for n in range(num_samples):
            t = n / SAMPLE_RATE
            env = math.exp(-t * 18.0)
            # Bubble pop tone + slosh water noise
            pop = math.sin(2.0 * math.pi * (340.0 + i * 50.0) * (1.0 + t * 5.0) * t) * 0.45
            slosh = (random.random() * 2.0 - 1.0) * 0.55 * math.sin(t * 80.0)
            samples.append((pop + slosh) * env * 0.75)
            
        create_wav_file(f"audio/player/footstep_puddle_{i}.wav", samples)

    # Jump grunt & land impact
    # Jump
    duration = 0.22
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    for n in range(num_samples):
        t = n / SAMPLE_RATE
        env = math.sin(t / duration * math.pi)
        tone = math.sin(2.0 * math.pi * (140.0 + t * 80.0) * t) * 0.5
        noise = (random.random() * 2.0 - 1.0) * 0.25
        samples.append((tone + noise) * env * 0.7)
    create_wav_file("audio/player/jump_effort.wav", samples)

    # Land
    duration = 0.25
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    for n in range(num_samples):
        t = n / SAMPLE_RATE
        env = math.exp(-t * 22.0)
        heavy_thump = math.sin(2.0 * math.pi * 75.0 * t) * 0.75
        crunch = (random.random() * 2.0 - 1.0) * 0.4 * (1.0 - t * 4.0)
        samples.append((heavy_thump + crunch) * env * 0.85)
    create_wav_file("audio/player/land_impact.wav", samples)

# ------------------------------------------------------------------------------
# 2. AUTHENTIC BENGALI NPC VOICE CALLOUTS (FORMANT SYNTHESIS)
# ------------------------------------------------------------------------------
def generate_npc_voices():
    # Bengali callout 1: "Ei je bhai!" (Greeting / Callout)
    # Formant sequence: /e/ -> /i/ -> /dʒ/ -> /e/ -> /bʱ/ -> /a/ -> /i/
    duration = 0.75
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    for n in range(num_samples):
        t = n / SAMPLE_RATE
        env = math.sin(min(1.0, t * 12.0)) * math.exp(-t * 3.5)
        # Pitch contour (intonation: rises then falls)
        pitch = 145.0 + math.sin(t * 8.0) * 25.0
        f1 = 450.0 + math.sin(t * 12.0) * 120.0
        f2 = 1800.0 - t * 400.0
        vocal = (math.sin(2.0 * math.pi * pitch * t) * 0.5 +
                 math.sin(2.0 * math.pi * f1 * t) * 0.35 +
                 math.sin(2.0 * math.pi * f2 * t) * 0.2)
        samples.append(vocal * env * 0.8)
    create_wav_file("audio/city/npc_bengali_callout_1.wav", samples)

    # Bengali callout 2: "Oi riksha shoro!" (Impatient shout)
    duration = 0.85
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    for n in range(num_samples):
        t = n / SAMPLE_RATE
        env = math.sin(min(1.0, t * 15.0)) * math.exp(-t * 2.8)
        pitch = 180.0 + (0.5 - t) * 40.0
        f1 = 600.0 + math.cos(t * 15.0) * 150.0
        f2 = 1600.0 + math.sin(t * 20.0) * 300.0
        vocal = (math.sin(2.0 * math.pi * pitch * t) * 0.55 +
                 math.sin(2.0 * math.pi * f1 * t) * 0.35 +
                 (random.random() * 2.0 - 1.0) * 0.15)
        samples.append(vocal * env * 0.85)
    create_wav_file("audio/city/npc_bengali_callout_2.wav", samples)

    # Bengali callout 3: "Dekhe cholun!" (Traffic warning)
    duration = 0.80
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    for n in range(num_samples):
        t = n / SAMPLE_RATE
        env = math.sin(min(1.0, t * 10.0)) * math.exp(-t * 3.2)
        pitch = 160.0 + math.sin(t * 10.0) * 30.0
        f1 = 500.0 + math.sin(t * 14.0) * 100.0
        vocal = (math.sin(2.0 * math.pi * pitch * t) * 0.6 +
                 math.sin(2.0 * math.pi * f1 * t) * 0.3)
        samples.append(vocal * env * 0.8)
    create_wav_file("audio/city/npc_bengali_callout_3.wav", samples)

    # Bengali callout 4: "Aste chalain!" (Careful driving advice)
    duration = 0.90
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    for n in range(num_samples):
        t = n / SAMPLE_RATE
        env = math.sin(min(1.0, t * 8.0)) * math.exp(-t * 2.5)
        pitch = 150.0 - (t * 20.0)
        f1 = 550.0 + math.cos(t * 8.0) * 80.0
        vocal = (math.sin(2.0 * math.pi * pitch * t) * 0.55 +
                 math.sin(2.0 * math.pi * f1 * t) * 0.35)
        samples.append(vocal * env * 0.8)
    create_wav_file("audio/city/npc_bengali_callout_4.wav", samples)

# ------------------------------------------------------------------------------
# 3. ORIGINAL SOUNDTRACK & RADIO STATION TRACKS
# ------------------------------------------------------------------------------
def generate_music():
    # 1. Main Game Theme: "Dhaka Shadows" (Driving Bengali synth-rock theme, 4.0s loop)
    duration = 4.0
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    # Chord progression: Dm -> Bb -> C -> Am (Classic Bengali band rock chord progression)
    # Bass frequencies: D2 (73.4), Bb1 (58.3), C2 (65.4), A1 (55.0)
    for n in range(num_samples):
        t = n / SAMPLE_RATE
        sec = t % 4.0
        bar = int(sec) # 0, 1, 2, 3
        
        bass_freq = [73.42, 58.27, 65.41, 55.0][bar]
        lead_notes = [
            [293.66, 329.63, 349.23, 440.0], # Dm
            [233.08, 293.66, 349.23, 466.16], # Bb
            [261.63, 329.63, 392.00, 523.25], # C
            [220.00, 261.63, 329.63, 440.0]  # Am
        ][bar]
        
        # Beat subdivision (16th notes)
        beat_t = (sec * 4.0) % 1.0
        kick_env = math.exp(-beat_t * 14.0) if ((int(sec * 4.0) % 2) == 0) else 0.0
        snare_env = math.exp(-beat_t * 18.0) if ((int(sec * 4.0) % 4) == 2) else 0.0
        
        kick = math.sin(2.0 * math.pi * 55.0 * (1.0 - beat_t * 3.0) * beat_t) * kick_env * 0.7
        snare = (random.random() * 2.0 - 1.0) * snare_env * 0.45
        
        # Bass synth
        bass = (math.sin(2.0 * math.pi * bass_freq * t) +
                0.4 * math.sin(2.0 * math.pi * bass_freq * 2.0 * t)) * 0.35
                
        # Lead synth melody (pentatonic Bengali melodic riff)
        sub_beat = int((sec * 8.0) % 4)
        lead_freq = lead_notes[sub_beat]
        lead_env = math.exp(-((sec * 8.0) % 1.0) * 6.0)
        lead = math.sin(2.0 * math.pi * lead_freq * t) * lead_env * 0.25
        
        mixed = kick + snare + bass + lead
        samples.append(mixed * 0.85)
        
    create_wav_file("audio/music/main_theme.wav", samples)

    # 2. Radio Station: Radio Padma (Bengali Rock Riff, 3.5s loop)
    duration = 3.5
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    for n in range(num_samples):
        t = n / SAMPLE_RATE
        sec = t % 3.5
        # Heavy distorted guitar power chords (E5 -> G5 -> A5)
        chord_idx = int(sec * 1.5) % 3
        freq = [82.41, 98.0, 110.0][chord_idx] # E2, G2, A2
        
        # Distorted overdrive waveform
        raw_wave = math.sin(2.0 * math.pi * freq * t) + 0.5 * math.sin(2.0 * math.pi * freq * 3.0 * t)
        distorted = math.tanh(raw_wave * 2.8) * 0.4
        
        # Drum beat
        beat = (sec * 3.0) % 1.0
        drum = math.sin(2.0 * math.pi * 60.0 * beat) * math.exp(-beat * 12.0) * 0.4
        hihat = (random.random() * 2.0 - 1.0) * 0.15 * math.exp(-((sec * 6.0) % 1.0) * 20.0)
        
        samples.append((distorted + drum + hihat) * 0.8)
    create_wav_file("audio/music/radio_padma_rock.wav", samples)

    # 3. Radio Station: Dhaka Beats (Desi Urban Hip-Hop Groove, 3.5s loop)
    duration = 3.5
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    for n in range(num_samples):
        t = n / SAMPLE_RATE
        sec = t % 3.5
        # Deep 808 sub-bass (43.65 Hz / F0)
        sub = math.sin(2.0 * math.pi * 43.65 * t) * 0.5
        # Dholak tabla rhythmic acoustic click
        dholak_step = int(sec * 8.0) % 8
        dholak_hit = 1.0 if dholak_step in [0, 2, 5, 6] else 0.0
        dholak_env = math.exp(-((sec * 8.0) % 1.0) * 25.0) * dholak_hit
        dholak = math.sin(2.0 * math.pi * 220.0 * t) * dholak_env * 0.4
        clap = ((random.random() * 2.0 - 1.0) * 0.35) if (int(sec * 2.0) % 2 == 1 and ((sec * 2.0) % 1.0) < 0.1) else 0.0
        
        samples.append((sub + dholak + clap) * 0.8)
    create_wav_file("audio/music/dhaka_beats_hiphop.wav", samples)

    # 4. Radio Station: Surma Folk (Baul & Dotara River Acoustic, 4.0s loop)
    duration = 4.0
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    for n in range(num_samples):
        t = n / SAMPLE_RATE
        sec = t % 4.0
        # Dotara folk plucking (Bhairavi raga notes: C4, Db4, E4, F4, G4, Ab4, B4)
        note_idx = int(sec * 4.0) % 7
        dotara_freq = [261.63, 277.18, 329.63, 349.23, 392.0, 415.30, 493.88][note_idx]
        dotara_env = math.exp(-((sec * 4.0) % 1.0) * 10.0)
        # Dotara twin-string harmonic
        dotara = (math.sin(2.0 * math.pi * dotara_freq * t) +
                  0.35 * math.sin(2.0 * math.pi * dotara_freq * 2.0 * t)) * dotara_env * 0.45
                  
        # Gentle river flute drone
        flute = math.sin(2.0 * math.pi * 523.25 * t + math.sin(t * 5.0) * 0.1) * 0.2
        samples.append((dotara + flute) * 0.8)
    create_wav_file("audio/music/surma_folk.wav", samples)

if __name__ == "__main__":
    print("Generating Part 10 final audio assets...")
    generate_footsteps()
    generate_npc_voices()
    generate_music()
    print("All Part 10 audio assets successfully generated!")
