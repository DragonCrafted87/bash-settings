#!/bin/bash

function podcast-download ()
{
    python -m podcast_downloader --config ~/bash-settings/config/podcast-downloader.json
}
