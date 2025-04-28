#!/bin/bash
for file in `find static/ -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" \)`; do
    if [ `identify -format '%w' $file` -gt 1500 ] || [ `identify -format '%h' $file` -gt 1500 ]; then
        echo "$file is too wide"
        mv $file{,.old}
        convert $file.old -resize 1000000@\> $file && rm $file.old 
        echo "image $file converted to `identify -format '%wx%h' $file`"
    fi
done

jpegoptim static/*/*/*.jpeg -m90 --strip-all
jpegoptim static/*/*/*.jpg -m90 --strip-all
find . -iname "*.png" -exec optipng -o5 -strip all {} \;
