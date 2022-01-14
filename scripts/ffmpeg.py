# -*- coding: utf-8 -*-

from argparse import ArgumentParser
from concurrent.futures import ThreadPoolExecutor
from concurrent.futures import as_completed as futures_as_completed
from glob import glob
from os import makedirs
from os import rename
from shutil import rmtree as rmdir
from subprocess import run

ENCODING_WORKERS = 8
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


def video_crop_encode(input_filename, output_filename):

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

    process = run_process(process_args)

    crop_data = [
        x.split("crop=")[1]
        for x in process.stderr.splitlines()[-32:]
        if "cropdetect" in x and "crop=" in x
    ]

    crop_value = crop_data[-1]

    makedirs("cropped", exist_ok=True)
    makedirs("original", exist_ok=True)

    process_args = [
        "ffmpeg",
        "-i",
        input_filename,
        "-vf",
        f"crop={crop_value}",
        "-map",
        "0:v",
        "-vcodec",
        "h264",
        "-map",
        "0:a",
        "-acodec",
        "flac",
        "-map",
        "0:s?",
        "-scodec",
        "copy",
        f"cropped/{output_filename}",
        "-y",
    ]

    run_process(process_args)

    rename(input_filename, f"original/{input_filename}")

    return output_filename


def encode_all_files():

    executor = get_encoding_executor()
    futures = []

    file_list = glob("*.mkv")
    for file_name in file_list:
        input_filename = file_name
        output_filename = file_name.rsplit(".", 1)[0] + ".mkv"

        futures.append(
            executor.submit(video_crop_encode, input_filename, output_filename)
        )

    print("Encoding", len(futures), "files.")

    for idx, future in enumerate(futures_as_completed(futures)):
        res = future.result()
        print("Processed job", idx, "result", res)


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

    if args.command == "encode":
        if not args.input_filename:
            encode_all_files()

        else:
            input_filename = args.input_filename
            output_filename = args.input_filename.rsplit(".", 1)[0] + ".mkv"

            video_crop_encode(input_filename, output_filename)

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
