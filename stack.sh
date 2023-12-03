#!/bin/bash
# MagickStack - Kevin M Henderson 2023

WIDTH=600 # max width only applies to vertical stack
HEIGHT=600 # max height only applies to horizontal stack
STACK_VERTICAL=0 # 1=vertical 0=horizontal
FONT_SIZE=$(($HEIGHT/40)) # can replace with simple int (ex. 32)
FONT_GRAVITY=SouthEast #North, NorthWest, Center, East, SouthEast, South, etc.
JPG_QUALITY=50
DATE=$(date +"%Y-%m-%d")

if [ $STACK_VERTICAL -eq 1 ]; then ORIENTATION="-append"; else ORIENTATION="+append"; fi

for f in *
do  # run only if dir contains >1 image
    if [ -d "$f" -a $(find -iname "*.jpg" -o -iname "*.jpeg" | wc -l) -gt 1 ]; then 
        cd $f && mkdir temp
        # copies all images into 'temp'
        find -iname "*.jpg" -o -iname "*.jpeg" | xargs -I {} cp {} temp/
        cd temp
  
        for img in *
        do
            echo $f/$img
            
            if [ $STACK_VERTICAL -eq 1 ]; then
            	convert "$img" -auto-orient -resize "$WIDTH" "$img"
            else
            	convert "$img" -auto-orient -resize "x$HEIGHT" "$img"
            fi
            
            convert "$img" -gravity $FONT_GRAVITY -pointsize $FONT_SIZE -fill black -annotate +2+2  %[exif:DateTimeOriginal] "$img"
            convert "$img" -gravity $FONT_GRAVITY -pointsize $FONT_SIZE -fill white -annotate +2+$((2+$FONT_SIZE)) %[exif:DateTimeOriginal] "$img"
        done

        convert $ORIENTATION ./* -auto-orient "$f"_"$DATE".png
        convert -strip -interlace Plane -gaussian-blur 0.05 -quality $JPG_QUALITY% "$f"_"$DATE".png "$f"_"$DATE".jpg
        mv "$f"_"$DATE".jpg ../../
        echo "~~$f"_"$DATE".jpg~~
        cd ..; rm -rf temp; cd .. # cleanup and leave dir
    fi
done
