#!/bin/bash

function gen {
    SKIP=$1
    DURATION=$2
    ADD=$3
    NAME=$4

    ffmpeg -y -ss $SKIP -t $DURATION -i ~/out-2.ogv -vf fps=10,scale=320:-1:flags=lanczos,palettegen palette.png

    ffmpeg -ss $SKIP -t $DURATION -i ~/out-2.ogv -i palette.png -filter_complex \
    "fps=48,scale=1024:-1:flags=lanczos[x];[x][1:v]paletteuse$ADD" $NAME.gif
}

# gen 1 85 ",setpts=0.5*PTS" configuration
# gen 175 8 ",setpts=0.5*PTS" deploy_template
gen 187 26 ",setpts=0.5*PTS" deploy
# gen 248 22 ",setpts=0.5*PTS" template_multiple_scripts
# gen 1 95 ",setpts=0.5*PTS" demo

