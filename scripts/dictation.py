#!/usr/bin/env python3

"""
Dictation script using pywhispercpp for real-time speech-to-text transcription with a local build integration via bindings.
"""

import argparse
import datetime
import os
import queue
import subprocess
import sys
import time

import numpy as np
import speech_recognition as sr
from pywhispercpp.model import Model


def pad_audio(audio_np, min_samples=32000):
    """
    Pad the audio with silence if it's shorter than min_samples.
    """
    if len(audio_np) < min_samples:
        padding = np.zeros(min_samples - len(audio_np), dtype=np.float32)
        audio_np = np.concatenate((audio_np, padding))
    return audio_np


def check_ollama_running():
    """
    Check if any Ollama models are running by parsing 'ollama ps' output.
    """
    try:
        output = subprocess.check_output(["ollama", "ps"],
                                         stderr=subprocess.STDOUT).decode("utf-8")
        lines = output.strip().splitlines()
        # Typically, first line is header; if more than 1 line, models are running
        if len(lines) > 1:
            print("Warning: Ollama models are currently running:")
            print(output)
            print("This may cause GPU memory conflicts. Try stopping them with "
                  "'ollama stop <model>' before proceeding.")
            # Optionally, exit or prompt user; for now, warn and proceed
            input("Press Enter to continue anyway, or Ctrl+C to abort...")
    except (subprocess.CalledProcessError, FileNotFoundError):
        # Ollama not installed or command failed; skip check
        print("Ollama not found or 'ollama ps' failed. Skipping Ollama running "
              "models check.")


def main():
    """
    Main function to handle argument parsing, microphone setup, model loading,
    and the transcription loop.
    """
    parser = argparse.ArgumentParser()
    parser.add_argument("--model", default="medium", help="Model to use",
                        choices=["tiny", "base", "small", "medium", "large"])
    parser.add_argument("--non_english", action='store_true',
                        help="Don't use the english model.")
    parser.add_argument("--models_dir", default=os.path.expanduser("~/ai/whisper-cpp/models"),
                        help="Directory to store and load models from.")
    parser.add_argument("--energy_threshold", default=1000,
                        help="Energy level for mic to detect.", type=int)
    parser.add_argument("--record_timeout", default=2,
                        help="How real time the recording is in seconds.", type=float)
    parser.add_argument("--phrase_timeout", default=3,
                        help="How much empty space between recordings before we "
                             "consider it a new line in the transcription.", type=float)
    if 'linux' in sys.platform:
        parser.add_argument("--default_microphone", default='pulse',
                            help="Default microphone name for SpeechRecognition. "
                                 "Run this with 'list' to view available Microphones.", type=str)
    args = parser.parse_args()

    if not os.path.exists(args.models_dir):
        os.makedirs(args.models_dir)

    if sys.maxsize < 2**32:
        print("Warning: Running on 32-bit Python. Large models may fail to load due "
              "to memory limits. Consider using 64-bit Python or a smaller model.")

    # Check for running Ollama models before loading Whisper
    check_ollama_running()

    # The last time a recording was retrieved from the queue.
    phrase_time = None
    # Thread safe Queue for passing data from the threaded recording callback.
    data_queue = queue.Queue()
    # Bytes object which holds audio data for the current phrase
    phrase_bytes = bytes()
    # We use SpeechRecognizer to record our audio because it has a nice feature where it can detect when speech ends.
    recorder = sr.Recognizer()
    recorder.energy_threshold = args.energy_threshold
    # Definitely do this, dynamic energy compensation lowers the energy threshold dramatically to a point where the SpeechRecognizer never stops recording.
    recorder.dynamic_energy_threshold = False

    # Important for linux users.
    # Prevents permanent application hang and crash by using the wrong Microphone
    if 'linux' in sys.platform:
        mic_name = args.default_microphone
        if not mic_name or mic_name == 'list':
            print("Available microphone devices are: ")
            for index, name in enumerate(sr.Microphone.list_microphone_names()):
                print(f"Microphone with name \"{name}\" found")
            return
        else:
            for index, name in enumerate(sr.Microphone.list_microphone_names()):
                if mic_name in name:
                    source = sr.Microphone(sample_rate=16000, device_index=index)
                    break
            else:
                print(f"Microphone with name containing \"{mic_name}\" not found")
                return
    else:
        source = sr.Microphone(sample_rate=16000)

    # Load / Download model
    model_name = args.model
    if args.model != "large" and not args.non_english:
        model_name += ".en"
    audio_model = Model(model_name, models_dir=args.models_dir)

    # Test model load with a small silent audio
    try:
        test_audio = np.zeros(32000, dtype=np.float32)
        test_audio = pad_audio(test_audio)
        audio_model.transcribe(test_audio, language='en')
    except Exception as e:
        print(f"Failed to load or test model: {e}")
        print("This may be due to insufficient memory. Try a smaller model, close "
              "other applications, or check your system configuration.")
        return

    record_timeout = args.record_timeout
    phrase_timeout = args.phrase_timeout

    transcription = ['']

    with source:
        recorder.adjust_for_ambient_noise(source)

    def record_callback(_, audio:sr.AudioData) -> None:
        """
        Threaded callback function to receive audio data when recordings finish.
        audio: An AudioData containing the recorded bytes.
        """
        # Grab the raw bytes and push it into the thread safe queue.
        data = audio.get_raw_data()
        data_queue.put(data)

    # Create a background thread that will pass us raw audio bytes.
    # We could do this manually but SpeechRecognizer provides a nice helper.
    recorder.listen_in_background(source, record_callback, phrase_time_limit=record_timeout)

    # Cue the user that we're ready to go.
    print("Model loaded.\n")

    while True:
        try:
            now = datetime.datetime.utcnow()
            # Pull raw recorded audio from the queue.
            if not data_queue.empty():
                phrase_complete = False
                # If enough time has passed between recordings, consider the phrase complete.
                # Clear the current working audio buffer to start over with the new data.
                if phrase_time and now - phrase_time > datetime.timedelta(seconds=phrase_timeout):
                    phrase_bytes = bytes()
                    phrase_complete = True
                # This is the last time we received new audio data from the queue.
                phrase_time = now

                # Combine audio data from queue
                audio_data_list = []
                while not data_queue.empty():
                    audio_data_list.append(data_queue.get())
                audio_data = b''.join(audio_data_list)

                # Add the new audio data to the accumulated data for this phrase
                phrase_bytes += audio_data

                # Convert in-ram buffer to something the model can use directly without needing a temp file.
                # Convert data from 16 bit wide integers to floating point with a width of 32 bits.
                # Clamp the audio stream frequency to a PCM wavelength compatible default of 32768hz max.
                audio_np = np.frombuffer(phrase_bytes, dtype=np.int16).astype(np.float32) / 32768.0

                # Pad audio if necessary
                audio_np = pad_audio(audio_np)

                # Read the transcription.
                language = 'en' if not args.non_english else None
                result = audio_model.transcribe(audio_np, language=language)
                text = ' '.join(segment.text.strip() for segment in result).strip()

                # If we detected a pause between recordings, add a new item to our transcription.
                # Otherwise edit the existing one.
                if phrase_complete:
                    transcription.append(text)
                else:
                    transcription[-1] = text

                # Clear the console to reprint the updated transcription.
                os.system('cls' if os.name=='nt' else 'clear')
                for line in transcription:
                    print(line)
                # Flush stdout.
                print('', end='', flush=True)
            else:
                # Infinite loops are bad for processors, must sleep.
                time.sleep(0.25)
        except KeyboardInterrupt:
            break

    print("\n\nTranscription:")
    for line in transcription:
        print(line)


if __name__ == "__main__":
    main()
