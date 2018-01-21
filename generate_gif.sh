#!/bin/bash

function gen {
    SKIP=$1
    DURATION=$2
    ADD=$3
    NAME=$4

    ffmpeg -y -ss $SKIP -t $DURATION -i ~/deployo.mp4 -vf fps=10,scale=320:-1:flags=lanczos,palettegen palette.png

    ffmpeg -ss $SKIP -t $DURATION -i ~/deployo.mp4 -i palette.png -filter_complex \
    "fps=48,scale=1024:-1:flags=lanczos[x];[x][1:v]paletteuse$ADD" $NAME.gif
}

# hello 7 58 ",setpts=0.5*PTS" configuration
# gen 65 5 ",setpts=0.5*PTS" deploy
gen 6 76 ",setpts=0.5*PTS" demo

