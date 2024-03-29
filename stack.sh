#!/bin/bash
# MagickStack - Kevin M Henderson 2023

WIDTH=1920 # max width only applies to vertical stack
HEIGHT=1080 # max height only applies to horizontal stack
STACK_VERTICAL=1 # 1=vertical 0=horizontal
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
            	RESIZE="$WIDTH"
            else
            	RESIZE="x$HEIGHT"
            fi
            
            convert "$img" 				\
            	-auto-orient -resize $RESIZE		\
            	-gravity $FONT_GRAVITY -pointsize $FONT_SIZE -fill black 	\
            	-annotate +2+2  %[exif:DateTimeOriginal] -fill white 		\
            	-annotate +2+$((2+$FONT_SIZE)) %[exif:DateTimeOriginal] 	\
            	"$img"
        done

        convert $ORIENTATION ./* -auto-orient -strip -interlace Plane -gaussian-blur 0.05 -quality $JPG_QUALITY% "$f"_"$DATE".jpg
        mv "$f"_"$DATE".jpg ../../
        echo "$f"_"$DATE".jpg
        cd ..; rm -rf temp # cleanup and leave dir
    fi
done
