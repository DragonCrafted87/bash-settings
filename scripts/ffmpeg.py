# -*- coding: utf-8 -*-

# built in libraries
from argparse import ArgumentParser
from concurrent.futures import ThreadPoolExecutor
from concurrent.futures import as_completed as futures_as_completed
from glob import glob
from json import load as read_json_file
from json import loads as read_json
from os import makedirs
from os import rename
from os.path import dirname
from pathlib import Path
from pprint import pprint
from shutil import rmtree as rmdir
from subprocess import run

# 3rd party libraries
from requests import get as http_get  # pylint: disable=import-error

ENCODING_WORKERS = 4
MAIN_WORKERS = 4

ENCODING_EXECUTOR = ThreadPoolExecutor(max_workers=ENCODING_WORKERS)


def get_encoding_executor():
    return ENCODING_EXECUTOR


def run_process(args, debug=False):
    process = run(args, capture_output=True, text=True, check=False)
    if debug:
        print(process.stderr)
        print(process.stdout)

    process.check_returncode()

    return process


# pylint: disable=too-many-statements
def video_crop_encode(input_filename, output_filename):

    print(f"Scanning: {input_filename}")
    try:
        process_args = [
            "ffprobe",
            "-v",
            "quiet",
            "-print_format",
            "json",
            "-show_format",
            "-show_streams",
            "-show_programs",
            "-show_chapters",
            input_filename,
        ]

        process = run_process(process_args)

        probe_data = read_json(process.stdout)

        codec_types = []
        for stream in probe_data["streams"]:
            codec_types.append(stream["codec_type"])

        process_args = [
            "ffmpeg",
            "-i",
            input_filename,
            "-vf",
            "cropdetect",
            "-f",
            "null",
            "-",
        ]

        process = run_process(process_args, debug=False)

        crop_data = [
            x.split("crop=")[1]
            for x in process.stderr.splitlines()[-32:]
            if "cropdetect" in x and "crop=" in x
        ]

        crop_value = crop_data[-1]

        makedirs("cropped", exist_ok=True)
        makedirs("original", exist_ok=True)

        print(f"Encoding: {input_filename}")
        process_args = []
        process_args.append("ffmpeg")
        process_args.append("-i")
        process_args.append(input_filename)
        process_args.append("-filter:v:0")
        process_args.append(f"crop={crop_value}")
        if "video" in codec_types:
            codec_types.remove("video")

            process_args.append("-map")
            process_args.append("0:v:0")
            process_args.append("-vcodec")
            process_args.append("h264")

        if "audio" in codec_types:
            for _ in range(codec_types.count("audio")):
                codec_types.remove("audio")
            process_args.append("-map")
            process_args.append("0:a")
            process_args.append("-acodec")
            process_args.append("flac")

        if "subtitle" in codec_types:
            for _ in range(codec_types.count("subtitle")):
                codec_types.remove("subtitle")
            process_args.append("-map")
            process_args.append("0:s")
            process_args.append("-scodec")
            process_args.append("copy")

        # thumbnail
        if "video" in codec_types:
            codec_types.remove("video")

            process_args.append("-map")
            process_args.append("0:v:1")

        if len(codec_types) != 0:
            raise Exception("We got extra unhandled streams")

        process_args.append(f"cropped/{output_filename}")
        process_args.append("-y")

        run_process(process_args, debug=False)

        print(f"Finalizing: {input_filename}")
        rename(input_filename, f"original/{input_filename}")

        return output_filename
    except Exception as exc:  # pylint: disable=broad-except
        print(f"{input_filename} generated an exception: {exc}")
    return f"Failed Processing {input_filename}"


def encode_all_video_files():

    executor = get_encoding_executor()
    futures = []

    file_list = glob("*.mkv") + glob("*.mp4")
    print(f"Encoding {len(file_list)} files.")
    for file_name in file_list:
        input_filename = file_name
        output_filename = file_name.rsplit(".", 1)[0] + ".mkv"

        futures.append(
            executor.submit(video_crop_encode, input_filename, output_filename)
        )

    for idx, future in enumerate(futures_as_completed(futures)):
        res = future.result()
        print(f"Finished Job {idx: >3}: {res}")


# pylint: disable=too-many-locals,unspecified-encoding,invalid-name
def audio_split_encode(input_filename):
    try:
        process_args = [
            "ffprobe",
            "-v",
            "quiet",
            "-print_format",
            "json",
            "-show_format",
            "-show_streams",
            "-show_programs",
            "-show_chapters",
            input_filename,
        ]

        process = run_process(process_args)

        probe_data = read_json(process.stdout)
        pprint(probe_data)

        author = probe_data["format"]["tags"]["artist"]
        print(author)
        summary = probe_data["format"]["tags"]["comment"]
        print(summary)
        title = probe_data["format"]["tags"]["title"].replace(":", " -")
        print(title)

        file_stream = http_get(
            f"https://www.audible.com/pd/{input_filename.split('_')[1]}", stream=True
        )
        audible_page = file_stream.content.decode("utf-8").split("\n")
        first_filter_pass = list(filter(lambda x: "Narrator" in x, audible_page))
        second_filter_pass = list(filter(lambda x: "search" in x, first_filter_pass))
        narrator = second_filter_pass[0].split(">")[1].split("<")[0]
        print(narrator)

        file_list = glob(
            f"{dirname(input_filename)}/*{input_filename.split('_')[1]}*.json"
        )
        pprint(file_list)
        with open(
            list(filter(lambda x: "content_metadata" in x, file_list))[0], "r"
        ) as f:
            content_metadata = read_json_file(f)["content_metadata"]
        pprint(content_metadata)

        with open(
            list(
                filter(
                    lambda x: "content_metadata" not in x and "series_titles" not in x,
                    file_list,
                )
            )[0],
            "r",
        ) as f:
            product_metadata = read_json_file(f)["product"]
        pprint(product_metadata)

        output_path = Path("S:\\Media\\Books\\Audiobooks")
        if "series" in product_metadata:
            print(product_metadata["series"][0]["sequence"])
            print(product_metadata["series"][0]["title"])

            output_path = output_path.joinpath(product_metadata["series"][0]["title"])
            output_path.mkdir(parents=True, exist_ok=True)
            output_path = output_path.joinpath(
                f"{product_metadata['series'][0]['sequence']} - {title}"
            )
        else:
            output_path = output_path.joinpath(f"{title}")

        pprint(output_path)
        output_path.mkdir(parents=True, exist_ok=True)

        cover_path = output_path.joinpath("cover.png")
        process_args = [
            "ffmpeg",
            "-i",
            input_filename,
            "-map",
            "0:v?",
            "-map",
            "0:V?",
            #        "-c",
            #        "copy",
            "-pix_fmt",
            "rgba64be",
            f"{cover_path}",
            "-y",
        ]

        run_process(process_args, debug=False)

    except Exception as exc:  # pylint: disable=broad-except
        print(f"{input_filename} generated an exception: {exc}")
    return f"Failed Processing {input_filename}"


def encode_all_audio_files():

    executor = get_encoding_executor()
    futures = []

    file_list = glob("*.aax")
    for file_name in file_list:
        input_filename = file_name

        futures.append(executor.submit(audio_split_encode, input_filename))

    print("Encoding", len(futures), "files.")

    for idx, future in enumerate(futures_as_completed(futures)):
        res = future.result()
        print("Finished Job", idx, "result", res)


def dvd_encode(input_filename, output_filename, folder_name, start_time, end_time):

    process_args = [
        "ffmpeg",
        "-i",
        input_filename,
        "-ss",
        start_time,
        "-to",
        end_time,
        "-target",
        "ntsc-dvd",
        f"{folder_name}/{output_filename}",
        "-y",
    ]

    run_process(process_args)

    return output_filename


def dvd_get_chapter_timestamps(input_filename):
    process_args = [
        "ffprobe",
        "-i",
        input_filename,
        "-show_chapters",
        "-loglevel",
        "error",
    ]

    process = run_process(process_args)

    chapter_breakpoints = [
        x.split("=")[1] for x in process.stdout.splitlines() if x.startswith("end_time")
    ]
    chapter_breakpoints.insert(0, "0.0")

    return chapter_breakpoints


def dvd_split_encode(input_filename, base_filename, folder_name):

    chapter_breakpoints = dvd_get_chapter_timestamps(input_filename)
    output_filename_list = []

    executor = get_encoding_executor()
    futures = []

    pad_count = len(str(len(chapter_breakpoints) - 1))
    for index in range(len(chapter_breakpoints) - 1):
        output_filename = (
            base_filename + "_" + str(index).rjust(pad_count, "0") + ".mpg"
        )
        output_filename_list.append(output_filename)

        start_time = chapter_breakpoints[index]
        end_time = chapter_breakpoints[index + 1]

        futures.append(
            executor.submit(
                dvd_encode,
                input_filename,
                output_filename,
                folder_name,
                start_time,
                end_time,
            )
        )

    print("Encoding", len(futures), "files.")

    for idx, future in enumerate(futures_as_completed(futures)):
        res = future.result()
        print("Processed job", idx, "result", res)

    return output_filename_list


def dvd_author_disk(folder_name, filename_list):

    with open(f"{folder_name}/dvd.xml", "w", encoding="utf8") as dvd_author_commands:
        dvd_author_commands.write("<dvdauthor>")
        dvd_author_commands.write("   <vmgm>")
        dvd_author_commands.write('      <menus lang="en">')
        dvd_author_commands.write('         <video format="ntsc" />')
        dvd_author_commands.write("      </menus>")
        dvd_author_commands.write("   </vmgm>")
        dvd_author_commands.write("    <titleset>")
        dvd_author_commands.write("        <titles>")
        dvd_author_commands.write("            <pgc>")
        for file_name in filename_list:
            dvd_author_commands.write(
                f'                <vob file="{folder_name}/{file_name}" />'
            )
        dvd_author_commands.write("            </pgc>")
        dvd_author_commands.write("        </titles>")
        dvd_author_commands.write("    </titleset>")
        dvd_author_commands.write("</dvdauthor>")

    process_args = [
        "dvdauthor",
        "-x",
        f"{folder_name}/dvd.xml",
        "-o",
        f"{folder_name}/dvd",
    ]

    run_process(process_args)


def dvd_make_iso(base_filename, folder_name):

    iso_name = f"{base_filename}.iso"
    process_args = [
        "mkisofs",
        "-dvd-video",
        "-volid",
        base_filename,
        "-o",
        iso_name,
        f"{folder_name}/dvd",
    ]

    run_process(process_args)
    return iso_name


def create_dvd(input_filename):

    base_filename = input_filename.rsplit(".", 1)[0]

    folder_name = base_filename + ".iso.temp"

    makedirs(f"{folder_name}/dvd", exist_ok=True)

    file_name_list = dvd_split_encode(input_filename, base_filename, folder_name)
    dvd_author_disk(folder_name, file_name_list)
    iso_name = dvd_make_iso(base_filename, folder_name)

    rmdir(f"{folder_name}")

    return iso_name


def main():
    parser = ArgumentParser(description="Get video information")
    parser.add_argument("command", help="What Are We Doin?")
    parser.add_argument("-i", "--input_filename", help="Input filename")
    args = parser.parse_args()

    print(args)

    if args.command == "video-crop-encode":
        if not args.input_filename:
            encode_all_video_files()

        else:
            input_filename = args.input_filename
            output_filename = args.input_filename.rsplit(".", 1)[0] + ".mkv"

            video_crop_encode(input_filename, output_filename)
    elif args.command == "audio-split-encode":
        if not args.input_filename:
            encode_all_audio_files()
        else:
            input_filename = args.input_filename
            audio_split_encode(input_filename)

    elif args.command == "make-dvd":
        if not args.input_filename:
            with ThreadPoolExecutor(max_workers=MAIN_WORKERS) as executor:

                file_list = glob("*.mkv")
                futures = []
                for file_name in file_list:
                    futures.append(executor.submit(create_dvd, file_name))

                print("Creating", len(futures), "dvds.")

                for idx, future in enumerate(futures_as_completed(futures)):
                    res = future.result()
                    print("Processed job", idx, "result", res)
        else:
            create_dvd(args.input_filename)


if __name__ == "__main__":
    main()
