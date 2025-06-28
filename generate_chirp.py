# generate_chirp.py

import numpy as np
from scipy.io.wavfile import write
import argparse

def generate_chirp_audio(text, output_file="chirp_output.wav",
                         sample_rate=44100,
                         duration_per_char=0.2,
                         f_start=1000,
                         f_step=1,
                         chirp_range=500):
    """
    Generates a chirp-modulated WAV audio file from the input text.
    
    Parameters:
    - text: str, the text to encode.
    - output_file: str, path to the output WAV file.
    - sample_rate: int, samples per second (Hz).
    - duration_per_char: float, seconds per character.
    - f_start: int, starting frequency for the first character (Hz).
    - f_step: int, frequency step per character's byte value.
    - chirp_range: int, additional frequency sweep range (Hz).
    """
    samples = []

    # Iterate over characters, convert to byte value
    for char in text:
        byte_val = ord(char)  # ensure integer
        freq_start = f_start + byte_val * f_step
        freq_end = freq_start + chirp_range
        frame_count = int(sample_rate * duration_per_char)
        t = np.linspace(0, duration_per_char, frame_count, endpoint=False)
        # Linear chirp: frequency sweeps from freq_start to freq_end
        instant_freq = freq_start + (freq_end - freq_start) * t / duration_per_char
        wave = 0.5 * np.sin(2 * np.pi * instant_freq * t)
        samples.extend(wave)

    audio = np.array(samples)
    # Normalize and convert to int16
    audio_int16 = np.int16(audio / np.max(np.abs(audio)) * 32767)
    write(output_file, sample_rate, audio_int16)
    print("Generated chirp audio: {}".format(output_file))

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Generate chirp-modulated WAV audio from text"
    )
    parser.add_argument("text", help="Text to encode (in quotes)")
    parser.add_argument("-o", "--output", default="chirp_output.wav",
                        help="Output WAV filename")
    args = parser.parse_args()
    generate_chirp_audio(args.text, args.output)

