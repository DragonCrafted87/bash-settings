#!/bin/bash

function ffmpeg-concatenate-videos ()
{
    # clear the file if it exists
    rm -f ffmpeg_file_list.txt

    # make the input file
    for f in *.mkv; do echo "file '$f'" >> ffmpeg_file_list.txt; done

    file_name="$*"

    # do the concatenation
    ffmpeg -f concat \
        -safe 0 \
        -i ffmpeg_file_list.txt \
        -map 0 \
        -c copy \
        -scodec copy \
        "$file_name.mkv"

    # final cleanup
    rm -f ffmpeg_file_list.txt
}
