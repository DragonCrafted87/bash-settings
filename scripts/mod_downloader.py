#!python
# -*- coding: utf-8 -*-


from argparse import ArgumentParser

# System Imports
from glob import glob
from os import getenv
from os import mkdir
from os import remove as delete_file
from pathlib import PurePath
from pprint import pprint
from re import search
from sys import exit as sys_exit
from urllib.parse import quote

# Local Imports
# https://docs.python-requests.org/en/master/
# pylint can't find requests for whatever reason even though its installed and works
from requests import get as http_get  # pylint: disable=import-error


def file_download(url, mods_folder):
    path, url = url
    file_stream = http_get(url, stream=True)

    mod_name = path[0 : search(r"\d", path).start() - 1]
    old_mod_prefix = str(PurePath(mods_folder, mod_name))
    mod_full_path = str(PurePath(mods_folder, path))

    pprint(f"Removing old version of: {old_mod_prefix}")
    old_mod_files = glob(f"{old_mod_prefix}*")
    for old_file in old_mod_files:
        try:
            delete_file(old_file)
        except OSError:
            pass

    pprint(f"Saving updated mod: {mod_full_path}")
    with open(mod_full_path, "wb") as new_file:
        new_file.write(file_stream.content)


def curseforge_parse(api_data, minecraft_version):
    if (
        minecraft_version in api_data["download"]["versions"]
        and "Fabric" in api_data["download"]["versions"]
    ):
        base_id = api_data["download"]["url"][
            api_data["download"]["url"].rfind("/") + 1 :
        ]
        url = (
            "https://media.forgecdn.net/files/"
            + str(int(base_id[0:4]))
            + "/"
            + str(int(base_id[4:7]))
            + "/"
            + quote(api_data["download"]["name"])
        )
        return (api_data["download"]["name"], url)

    for item in api_data["files"]:
        if minecraft_version in item["versions"] and "Fabric" in item["versions"]:
            base_id = item["url"][item["url"].rfind("/") + 1 :]
            url = (
                "https://media.forgecdn.net/files/"
                + str(int(base_id[0:4]))
                + "/"
                + str(int(base_id[4:7]))
                + "/"
                + quote(item["name"])
            )
            return (item["name"], url)
    return None


def github_parse(api_data, minecraft_version):
    for releases in api_data:
        if not bool(
            releases.get("prerelease", True)
        ) and minecraft_version in releases.get("name").split(" "):
            for assets in releases["assets"]:
                link = assets.get("browser_download_url")
                if (
                    link is not None
                    and link.endswith("jar")
                    and minecraft_version in link
                ):
                    return (link[link.rfind("/") + 1 :], link)
    return None


def parse_mod_list(mod_list, minecraft_version, secondary_version):
    pprint("Parsing Mod List")
    download_list = []
    for url in mod_list:

        for _ in range(5):
            api_data = http_get(url)
            if api_data.status_code == 200:
                break

        if api_data.status_code != 200:
            pprint(f"Failed to get data for {url}")
            continue

        pprint(f"Getting data for {url}")
        if "github" in url:
            parse_function = github_parse
        elif "cfwidget" in url:
            parse_function = curseforge_parse
        else:
            continue

        download_link = parse_function(api_data.json(), minecraft_version)
        if download_link is None and secondary_version is not None:
            download_link = parse_function(api_data.json(), secondary_version)

        if download_link is not None:
            download_list.append(download_link)

    return download_list


def main():

    argument_parser = ArgumentParser()
    argument_parser.add_argument("mod_list_path")
    argument_parser.add_argument("mods_folder")
    args = argument_parser.parse_args()

    if args.mod_list_path is None:
        pprint("Mod List Not Found")
        sys_exit()

    with open(f"{args.mod_list_path}", "r") as mod_list_file:
        mod_list = [line.strip() for line in mod_list_file.readlines()]

    mod_list = list(filter(lambda x: x, mod_list))
    mod_list = list(filter(lambda x: not x.startswith("#"), mod_list))

    minecraft_version = getenv("MINECRAFT_VERSION", "1.17")
    secondary_version = None

    if minecraft_version.count(".") == 2:
        secondary_version = minecraft_version[: minecraft_version.rfind(".")]

    pprint(f"Getting Mods for MineCraft Version {minecraft_version}")

    download_list = parse_mod_list(mod_list, minecraft_version, secondary_version)

    try:
        mkdir(args.mods_folder)
    except OSError:
        pass

    pprint("Downloading Mods")
    for download_link in download_list:
        file_download(download_link, args.mods_folder)

    pprint("All Installed Mods")
    pprint(glob(f"{str(PurePath(args.mods_folder,'*'))}"))


if __name__ == "__main__":
    main()
