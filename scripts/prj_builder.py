#!python
# -*- coding: utf-8 -*-

from os import walk
from pathlib import PurePath

BANNED_FILE_SUBSTRINGS = [
    "prj",
    "pui",
]
BANNED_GROUP_SUBSTRINGS = [
    ".git ",
    ".kube",
    ".cache",
    ".gnupg",
    ".local",
    ".dvdcss",
    ".dbus_keyrings",
    ".openshot_qt",
    "node_modules",
]
BANNED_GROUP_ENDINGS = [
    ".git",
]


def main():  # pylint: disable=too-many-locals
    file_list = ["[FilesU]"]
    group_list = ["[GroupU]"]
    group_file_list = []
    group_index = 0

    for root, _, files in walk("D:\\git-home"):
        group_path = PurePath(root).relative_to("D:\\git-home")
        group_parts = list(group_path.parts)

        for loop_index, _ in enumerate(group_parts):
            group_parts[loop_index] = group_parts[loop_index].replace("-", "_")
        group_formatted = " - ".join(group_parts).strip()

        if group_formatted == "":
            file_index = 0
            for file_name in files:
                if not any(
                    substring in file_name for substring in BANNED_FILE_SUBSTRINGS
                ):
                    formatted_file_name = file_name.replace("_", "+AF8-")
                    file_list.append(f"{file_index}={formatted_file_name}")
                    file_index += 1

        elif any(
            substring in group_formatted for substring in BANNED_GROUP_SUBSTRINGS
        ) or any(map(group_formatted.endswith, BANNED_GROUP_ENDINGS)):
            continue

        else:
            group_formatted = group_formatted.replace("_", "+AF8-")

            group_list.append(f"{group_index}={group_formatted}")
            group_index += 1

            group_file_list.append(f"[FilesU - {group_formatted}]")

            escaped_root = str(group_path).replace("\\", "+AFw-").replace("_", "+AF8-")

            file_index = 0
            for file_name in files:
                group_file_list.append(f"{file_index}={escaped_root}+AFw-{file_name}")
                file_index += 1

    with open(
        "D:\\git-home\\main.prj", "w", newline="\r\n", encoding="utf8"
    ) as prj_file:
        print("[Project ID]", file=prj_file)
        print(" Signature=UE Proj: v.1", file=prj_file)
        print("[Project Information]", file=prj_file)
        print(" Use Relative Directory=1", file=prj_file)
        print(" Relative to Project File=1", file=prj_file)
        print(" Filter=", file=prj_file)
        print(" Include Sub Directories=1", file=prj_file)
        print(" Project Tagfile=", file=prj_file)
        print(" Project Wordfile=", file=prj_file)
        print(" Project TpFile=", file=prj_file)
        print(" Create Tagfile=0", file=prj_file)

        for line in file_list:
            print(line, file=prj_file)

        for line in group_list:
            print(line, file=prj_file)

        for line in group_file_list:
            print(line, file=prj_file)


if __name__ == "__main__":
    main()
