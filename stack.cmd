echo off
:;# MagickStack - Kevin M Henderson - 2023
:;set() { eval $1; }

set WIDTH=1920 # max width only applies to vertical stack
set HEIGHT=1920 # max height only applies to horizontal stack
set STACK_VERTICAL=1 # 1=vertical 0=horizontal
set FONT_SIZE=15 # can replace with simple int (ex. FONT_SIZE=32)
set FONT_GRAVITY=SouthEast  # North, NorthWest, Center, East, SouthEast, South, etc.
set JPG_QUALITY=75
set DATE=%date%

goto(){
	:;# <---- START LINUX CODE ---->
	DATE=$(date +"%Y-%m-%d")
	for f in *
	do  # run only if dir contains >1 image
		if [ -d "$f" -a $(find -iname "*.jpg" -o -iname "*.jpeg" | wc -l) -gt 1 ]; then
			cd $f && mkdir temp # copying all images into 'temp'
			find -iname "*.jpg" -o -iname "*.jpeg" | xargs -I {} cp {} temp/ && cd temp

			for img in *
			do echo "processing $f/$img"
				if [ $STACK_VERTICAL -eq 1 ]; then ORIENTATION="-append" && NEW_SIZE="$WIDTH"
				else ORIENTATION="+append" && NEW_SIZE="x$HEIGHT"
				fi
				convert "$img" -auto-orient -resize $NEW_SIZE "$img"
				convert "$img" -gravity $FONT_GRAVITY -pointsize $FONT_SIZE -fill black -annotate +2+2  %[exif:DateTimeOriginal] "$img" 2> /dev/null
				convert "$img" -gravity $FONT_GRAVITY -pointsize $FONT_SIZE -fill white -annotate +2+$((2+$FONT_SIZE)) %[exif:DateTimeOriginal] "$img" 2> /dev/null
			done

			convert $ORIENTATION ./* -auto-orient "$f"_"$DATE".png
			convert -strip -interlace Plane -gaussian-blur 0.05 -quality $JPG_QUALITY% "$f"_"$DATE".png "$f"_"$DATE".jpg
			mv "$f"_"$DATE".jpg ../../
			cd .. && rm -rf temp && cd .. # cleanup and leave dir
			echo "created file: $f"_"$DATE".jpg
		fi
	done
	:;# <---- END LINUX CODE ---->
}


goto $@
exit

:(){
	:;# <---- START WINDOWS CODE ---->
	@echo off
	setlocal enabledelayedexpansion

	if %STACK_VERTICAL% equ 1 (
		set "ORIENTATION=-append"
	) else (
		set "ORIENTATION=+append"
	)

	for /d %%f in (*) do (
		REM run only if dir contains >1 image
		set /a COUNT=0
		for %%i in (%%f\*.jpg %%f\*.jpeg) do set /a COUNT+=1

		if !COUNT! gtr 1 (
			pushd "%%f" && mkdir temp
			REM copies all images into 'temp'
			copy *.jpg temp\ 1>NUL 2>NUL
			copy *.jpeg temp\ 1>NUL 2>NUL

			pushd temp
			for %%i in (*.jpg) do (
				echo %%i
				if %STACK_VERTICAL% equ 1 (
					magick convert "%%i" -auto-orient -resize %WIDTH% "%%i"
				) else (
					magick convert "%%i" -auto-orient -resize x%HEIGHT% "%%i"
				)

				magick convert "%%i" -gravity %FONT_GRAVITY% -pointsize !FONT_SIZE! -fill black -annotate +2+2 "%%[exif:DateTimeOriginal]" "%%i" 1>NUL 2>NUL
				magick convert "%%i" -gravity %FONT_GRAVITY% -pointsize !FONT_SIZE! -fill white -annotate +2+!FONT_SIZE! "%%[exif:DateTimeOriginal]" "%%i" 1>NUL 2>NUL
			)

			magick convert %ORIENTATION% * -auto-orient "..\%%f_%DATE%.png"
			magick convert -strip -interlace Plane -gaussian-blur 0.05 -quality %JPG_QUALITY%%% "..\%%f_%DATE%.png" "..\..\%%f_%DATE%.jpg"
			echo %%f_%DATE%.jpg
			popd && rmdir /s /q temp
		)
	)
	:;# <---- END WINDOWS CODE ---->
exit
