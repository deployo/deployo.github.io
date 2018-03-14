#!/bin/bash

NAME=$1

ffmpeg -i static/img/$NAME.gif -movflags faststart -pix_fmt yuv420p -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" static/img/$NAME.mp4