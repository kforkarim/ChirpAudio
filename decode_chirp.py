# decode_chirp_matched_filter.py

import numpy as np
from scipy.io.wavfile import read
import argparse
import os

def generate_template(byte_val, frame_count, sample_rate, duration, f_start, f_step, chirp_range):
    """
    Create a chirp template for a given byte value.
    """
    t = np.linspace(0, duration, frame_count, endpoint=False)
    freq_start = f_start + byte_val * f_step
    freq_end = freq_start + chirp_range
    instant_freq = freq_start + (freq_end - freq_start) * t / duration
    return np.sin(2 * np.pi * instant_freq * t)

def decode_chirp_audio(input_file,
                       duration_per_char=0.2,
                       f_start=1000,
                       f_step=1,
                       chirp_range=500):
    """
    Decode chirp-modulated WAV audio via matched filtering.
    """
    # Read WAV file
    sr, data = read(input_file)
    if data.ndim > 1:
        data = data[:, 0]
    audio = data.astype(np.float32)
    if np.max(np.abs(audio)) > 0:
        audio /= np.max(np.abs(audio))

    frame_count = int(sr * duration_per_char)
    num_frames = len(audio) // frame_count

    # Precompute templates
    templates = np.array([
        generate_template(b, frame_count, sr, duration_per_char, f_start, f_step, chirp_range)
        for b in range(256)
    ])

    decoded = []
    for i in range(num_frames):
        chunk = audio[i*frame_count:(i+1)*frame_count]
        # Compute correlation with each template
        # Normalize chunk
        chunk_norm = chunk / np.linalg.norm(chunk) if np.linalg.norm(chunk) > 0 else chunk
        # Normalize templates
        temps_norm = templates / np.linalg.norm(templates, axis=1)[:, None]
        corrs = temps_norm.dot(chunk_norm)
        byte_val = int(np.argmax(corrs))
        decoded.append(chr(byte_val))

    return ''.join(decoded)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Decode chirp WAV via matched filter")
    parser.add_argument("input", help="Input WAV file")
    parser.add_argument("-d", "--duration", type=float, default=0.2,
                        help="Duration per char (s)")
    parser.add_argument("--fstart", type=float, default=1000,
                        help="Starting frequency (Hz)")
    parser.add_argument("--fstep", type=float, default=1,
                        help="Frequency step per char (Hz)")
    parser.add_argument("--range", type=float, default=500,
                        help="Chirp range (Hz)")
    args = parser.parse_args()

    if not os.path.isfile(args.input):
        print("File not found: {}".format(args.input))
        exit(1)

    text = decode_chirp_audio(args.input,
                              duration_per_char=args.duration,
                              f_start=args.fstart,
                              f_step=args.fstep,
                              chirp_range=args.range)
    print("Decoded text:", text)
