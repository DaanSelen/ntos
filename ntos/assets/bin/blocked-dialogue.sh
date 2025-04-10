#!/bin/bash

block_dialogue() {
    yad --title='Credcon Utility' \
    --text="\nThis operation has been blocked.\nIf you require this, contact your administrator." \
    --button='Okay':0 \
    --width=400 \
    --height=225 \
    --auto-kill \
    --center \
    --text-align=center
}

block_dialogue
exit 0