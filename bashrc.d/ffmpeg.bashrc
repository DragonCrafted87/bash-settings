#!/bin/bash

function ffmpeg-video-encode ()
{
    mkdir -p "encoded"
    mkdir -p "original"

    video_codec="h264"
    audio_codec="flac"

    filename=$(basename "$1")
    filename="${filename%.*}"
    filename="$filename.mkv"
    output_file_name="encoded/$filename"

    ffmpeg -y -i "$1" \
        -acodec $audio_codec \
        -vcodec $video_codec \
        -scodec copy \
        "$output_file_name"

    mv "$1" "original/$1"

}

function ffmpeg-video-folder-transcode ()
{
    extension="$1"

    if [[ "$2" =~ ^[0-9]+$ ]] ; then
        num_to_encode_at_once=$2
    else
        num_to_encode_at_once=1
    fi

    k=1
    for f in *."$extension"
    do
        ffmpeg-video-encode "$f" &

        if [[ $((k%num_to_encode_at_once)) -eq 0 ]]; then
            wait
        fi

        k=$((k+1))
    done
    wait
}

function ffmpeg-concatenate-videos ()
{
    file_list_file=$(mktemp ./ffmpeg_file_list.XXXXXXXXX)

    for ((i=2;i<=$#;i++))
    do
        echo "file '${!i}'" >> "$file_list_file"
    done

    output_file_name="$1.mkv"

    #    video_codec="h264"
    #    audio_codec="flac"

    video_codec="copy"
    audio_codec="copy"

    ffmpeg -f concat \
        -safe 0 \
        -i "$file_list_file" \
        -map 0 \
        -c copy \
        -acodec $audio_codec \
        -vcodec $video_codec \
        -scodec copy \
        "$output_file_name"

    rm -f "$file_list_file"
}

function ffmpeg-video-split-by-timestamps ()
{
    #    video_codec="$(ffprobe -loglevel error -select_streams v:0 -show_entries stream=codec_name -of default=nk=1:nw=1 "$1.mkv")"
    #    audio_codec="$(ffprobe -loglevel error -select_streams a:0 -show_entries stream=codec_name -of default=nk=1:nw=1 "$1.mkv")"
    #    subtitle_codec="$(ffprobe -loglevel error -select_streams s:0 -show_entries stream=codec_name -of default=nk=1:nw=1 "$1.mkv")"

    #    video_codec="h264"
    #    audio_codec="flac"
    #    subtitle_codec="$(ffprobe -loglevel error -select_streams s:0 -show_entries stream=codec_name -of default=nk=1:nw=1 "$1.mkv")"

    video_codec="copy"
    audio_codec="copy"
    subtitle_codec="copy"

    filename=$(basename "$file")
    filename="${filename%.*}"

    if [[ "$3" ]]; then
        k=1
        j=2

        for ((i=3;i<=$#;i++))
        do
            # shellcheck disable=SC2027 # This is actually what we want
            output_file_name=$filename"_split"$(printf '_%03s' $k)".mkv"

            echo ${!j} "${!i}" "$output_file_name"

            ffmpeg -y -i "$1" \
                -ss ${!j} -to "${!i}" \
                -acodec $audio_codec \
                -vcodec $video_codec \
                -scodec $subtitle_codec \
                "$output_file_name" &

            if [[ $((k%3)) -eq 0 ]]; then
                wait
            fi

            k=$((k+1))
            j=$((j+1))
        done
    else
        output_file_name=$filename"_split_001.mkv"
        end_time=$(ffmpeg-get-end-timestamp "$1")

        echo "$end_time"

        ffmpeg -y -i "$1" \
            -ss "$2" -to "$end_time" \
            -acodec $audio_codec \
            -vcodec $video_codec \
            -scodec copy \
            "$output_file_name" &
    fi
    wait
}

function ffmpeg-video-split-by-chapters ()
{
    file="$1"
    if [ -z "$file" ]; then
        echo "Missing file argument!"
        exit 1
    fi

    filename=$(basename "$file")
    filename="${filename%.*}"

    # shellcheck disable=SC2207 # Don't want to rework it yet
    timestamp_list=($(ffprobe -i "$filename.mkv" -show_chapters -loglevel error | grep end_time | cut -d '=' -f 2 ))

    ffmpeg_command="ffmpeg-split-video $filename 0.00 "
    for i in "${timestamp_list[@]}";
    do
        ffmpeg_command=$ffmpeg_command"$i "

    done

    echo "$ffmpeg_command"
    eval "$ffmpeg_command"
}

function ffmpeg-video-merge-chapters ()
{
    base_command='ffmpeg-concatenate-videos '
    file_extension='.mkv '
    base_file=$1
    chapters_per_episode=$2
    total_chapters=$3

    total_episodes=$total_chapters/$chapters_per_episode

    chapter=0
    for ((episode=1;episode<=total_episodes;episode++))
    do
        file_list=""
        for ((i=1;i<=chapters_per_episode;i++))
        do
            file_list=$file_list"split"$(printf '_%03s_of_' $chapter)$base_file$file_extension
            chapter=$((chapter+1))
        done
        ffmpeg_command=$base_command$base_file$(printf '_e%03d ' "$episode")$file_list
        echo "$ffmpeg_command"
        eval "$ffmpeg_command"
    done

}

function ffmpeg-get-end-timestamp ()
{
    file="$1"
    if [ -z "$file" ]; then
        echo "Missing file argument!"
        exit 1
    fi

    filename=$(basename "$file")
    filename="${filename%.*}"

    end_timestamp=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$filename.mkv")
    echo "$end_timestamp"
}

function ffmpeg-video-crop-detection ()
{
    ffmpeg -i "$1" -vf cropdetect -f null -
}

function ffmpeg-video-crop-encode ()
{
    mkdir -p "cropped"
    mkdir -p "original"

    video_codec="h264"
    audio_codec="flac"

    filename=$(basename "$1")
    filename="${filename%.*}"
    filename="$filename.mkv"
    output_file_name="cropped/$filename"

    ffmpeg -y -i "$1" \
        -vf crop="$2" \
        -acodec $audio_codec \
        -vcodec $video_codec \
        -scodec copy \
        "$output_file_name"

    mv "$1" "original/$1"
}

#ffmpeg-split-video Pokemon_Master_Quest_D1_t00 00:00:00 00:41:09 01:20:41
#ffmpeg-split-video-by-chapters Pokemon_Master_Quest_D7_t00.mkv
#ffmpeg-merge-videos-by-chapters Pokemon_Master_Quest_D1_t00 4 36
