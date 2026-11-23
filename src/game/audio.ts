/**
 * DTA: Dhaka Theft Auto - Procedural Web Audio Engine
 * Real-time synthesis for engine pitch, Dhaka CNG honks, bus horns, rickshaw bells & radio
 */

class SoundEngine {
  private ctx: AudioContext | null = null;
  private isMuted: boolean = false;
  private engineOsc: OscillatorNode | null = null;
  private engineGain: GainNode | null = null;

  constructor() {
    // AudioContext is initialized on first user interaction to comply with browser autoplay policies
  }

  private initContext() {
    if (!this.ctx) {
      const AudioCtx = window.AudioContext || (window as unknown as { webkitAudioContext: typeof AudioContext }).webkitAudioContext;
      this.ctx = new AudioCtx();
    }
    if (this.ctx.state === 'suspended') {
      this.ctx.resume();
    }
  }

  public setMuted(muted: boolean) {
    this.isMuted = muted;
    if (this.engineGain && this.ctx) {
      this.engineGain.gain.setValueAtTime(muted ? 0 : 0.06, this.ctx.currentTime);
    }
  }

  // Starts or updates continuous vehicle engine hum
  public updateEngine(speed: number, maxSpeed: number, isInVehicle: boolean) {
    if (this.isMuted) return;
    this.initContext();
    if (!this.ctx) return;

    if (!isInVehicle) {
      if (this.engineOsc) {
        this.engineOsc.stop();
        this.engineOsc.disconnect();
        this.engineOsc = null;
        this.engineGain = null;
      }
      return;
    }

    if (!this.engineOsc) {
      this.engineOsc = this.ctx.createOscillator();
      this.engineGain = this.ctx.createGain();

      this.engineOsc.type = 'sawtooth';
      this.engineOsc.frequency.setValueAtTime(45, this.ctx.currentTime);

      // Low pass filter for warm engine rumble
      const filter = this.ctx.createBiquadFilter();
      filter.type = 'lowpass';
      filter.frequency.setValueAtTime(260, this.ctx.currentTime);

      this.engineGain.gain.setValueAtTime(0.06, this.ctx.currentTime);

      this.engineOsc.connect(filter);
      filter.connect(this.engineGain);
      this.engineGain.connect(this.ctx.destination);
      this.engineOsc.start();
    }

    const ratio = Math.min(1.0, Math.abs(speed) / Math.max(1, maxSpeed));
    const targetFreq = 45 + ratio * 130;
    this.engineOsc.frequency.setTargetAtTime(targetFreq, this.ctx.currentTime, 0.08);
  }

  // Classic Dhaka CNG Sharp Double Honk ("Pee-Peep!")
  public playCNGHorn() {
    if (this.isMuted) return;
    this.initContext();
    if (!this.ctx) return;

    const now = this.ctx.currentTime;
    [0, 0.12].forEach((offset) => {
      const osc = this.ctx!.createOscillator();
      const gain = this.ctx!.createGain();

      osc.type = 'triangle';
      osc.frequency.setValueAtTime(540, now + offset);
      osc.frequency.exponentialRampToValueAtTime(510, now + offset + 0.08);

      gain.gain.setValueAtTime(0.18, now + offset);
      gain.gain.exponentialRampToValueAtTime(0.001, now + offset + 0.08);

      osc.connect(gain);
      gain.connect(this.ctx!.destination);
      osc.start(now + offset);
      osc.stop(now + offset + 0.09);
    });
  }

  // Melodic Dhaka Bus Air Horn
  public playBusHorn() {
    if (this.isMuted) return;
    this.initContext();
    if (!this.ctx) return;

    const now = this.ctx.currentTime;
    const chords = [392, 440, 523.25]; // G4, A4, C5
    chords.forEach((freq) => {
      const osc = this.ctx!.createOscillator();
      const gain = this.ctx!.createGain();

      osc.type = 'sawtooth';
      osc.frequency.setValueAtTime(freq, now);

      gain.gain.setValueAtTime(0.12, now);
      gain.gain.exponentialRampToValueAtTime(0.001, now + 0.35);

      osc.connect(gain);
      gain.connect(this.ctx!.destination);
      osc.start(now);
      osc.stop(now + 0.36);
    });
  }

  // Rickshaw Bell Ring ("Tring-Tring")
  public playRickshawBell() {
    if (this.isMuted) return;
    this.initContext();
    if (!this.ctx) return;

    const now = this.ctx.currentTime;
    [0, 0.08].forEach((offset) => {
      const osc = this.ctx!.createOscillator();
      const gain = this.ctx!.createGain();

      osc.type = 'sine';
      osc.frequency.setValueAtTime(1480, now + offset);

      gain.gain.setValueAtTime(0.15, now + offset);
      gain.gain.exponentialRampToValueAtTime(0.001, now + offset + 0.06);

      osc.connect(gain);
      gain.connect(this.ctx!.destination);
      osc.start(now + offset);
      osc.stop(now + offset + 0.07);
    });
  }

  // Cash / Coin Reward Pickup sound (BDT ৳ earned)
  public playCashEarned() {
    if (this.isMuted) return;
    this.initContext();
    if (!this.ctx) return;

    const now = this.ctx.currentTime;
    const notes = [587.33, 880, 1174.66]; // D5, A5, D6
    notes.forEach((freq, idx) => {
      const osc = this.ctx!.createOscillator();
      const gain = this.ctx!.createGain();

      osc.type = 'sine';
      osc.frequency.setValueAtTime(freq, now + idx * 0.07);

      gain.gain.setValueAtTime(0.2, now + idx * 0.07);
      gain.gain.exponentialRampToValueAtTime(0.001, now + idx * 0.07 + 0.14);

      osc.connect(gain);
      gain.connect(this.ctx!.destination);
      osc.start(now + idx * 0.07);
      osc.stop(now + idx * 0.07 + 0.15);
    });
  }

  // Mission Complete Fanfare
  public playMissionComplete() {
    if (this.isMuted) return;
    this.initContext();
    if (!this.ctx) return;

    const now = this.ctx.currentTime;
    const notes = [440, 554.37, 659.25, 880]; // A4, C#5, E5, A5
    notes.forEach((freq, idx) => {
      const osc = this.ctx!.createOscillator();
      const gain = this.ctx!.createGain();

      osc.type = 'triangle';
      osc.frequency.setValueAtTime(freq, now + idx * 0.12);

      gain.gain.setValueAtTime(0.25, now + idx * 0.12);
      gain.gain.exponentialRampToValueAtTime(0.001, now + idx * 0.12 + 0.3);

      osc.connect(gain);
      gain.connect(this.ctx!.destination);
      osc.start(now + idx * 0.12);
      osc.stop(now + idx * 0.12 + 0.32);
    });
  }

  // Police Siren Wail
  public playPoliceSiren() {
    if (this.isMuted) return;
    this.initContext();
    if (!this.ctx) return;

    const now = this.ctx.currentTime;
    const osc = this.ctx.createOscillator();
    const gain = this.ctx.createGain();

    osc.type = 'sawtooth';
    osc.frequency.setValueAtTime(600, now);
    osc.frequency.linearRampToValueAtTime(950, now + 0.35);
    osc.frequency.linearRampToValueAtTime(600, now + 0.7);

    gain.gain.setValueAtTime(0.12, now);
    gain.gain.exponentialRampToValueAtTime(0.001, now + 0.72);

    osc.connect(gain);
    gain.connect(this.ctx.destination);
    osc.start(now);
    osc.stop(now + 0.73);
  }
}

export const soundEngine = new SoundEngine();
