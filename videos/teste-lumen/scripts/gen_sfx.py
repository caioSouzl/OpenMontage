"""Generate the discreet digital beeps for the LUMEN piece (stdlib only).

One short, soft sine "blip" per text block, synced to the timeline in
index.html. Output: audio/sfx.wav (10 s, 48 kHz, mono, 16-bit), peak ~ -22 dBFS
so the SFX sit well below the narration.
"""
import math
import struct
import wave
from pathlib import Path

SR = 48000
DUR = 10.0
PEAK = 10 ** (-22 / 20)  # ~ -22 dBFS

# (time_s, freq_hz, length_s, gain) — one entry per text block appearance
EVENTS = [
    (2.10, 1320, 0.09, 1.00),  # [ ANÁLISE CONCLUÍDA ]
    (2.90, 1480, 0.09, 1.00),  # [ NOVA HABILIDADE ADQUIRIDA ]
    (4.20, 1760, 0.12, 1.00),  # [ HABILIDADE: PERCEPÇÃO ACELERADA ]
    (4.90, 1175, 0.08, 0.70),  # descrição
    (7.25, 1320, 0.09, 1.00),  # [ RELATÓRIO ]
    (7.75, 988, 0.14, 0.80),   # mensagem final
]


def blip(n, f, length, gain, buf):
    count = int(length * SR)
    attack = int(0.006 * SR)
    for i in range(count):
        t = i / SR
        env = min(1.0, i / attack) * math.exp(-t / (length * 0.32))
        # fundamental + a quiet octave for a clean "digital" tone
        s = math.sin(2 * math.pi * f * t) + 0.18 * math.sin(2 * math.pi * 2 * f * t)
        idx = n + i
        if idx < len(buf):
            buf[idx] += s * env * gain


def main():
    total = int(DUR * SR)
    buf = [0.0] * total
    for t0, f, length, gain in EVENTS:
        blip(int(t0 * SR), f, length, gain, buf)
    peak = max(abs(x) for x in buf) or 1.0
    scale = PEAK / peak
    out = Path(__file__).resolve().parent.parent / "audio" / "sfx.wav"
    out.parent.mkdir(parents=True, exist_ok=True)
    with wave.open(str(out), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(b"".join(struct.pack("<h", int(x * scale * 32767)) for x in buf))
    print(f"wrote {out}")


if __name__ == "__main__":
    main()
