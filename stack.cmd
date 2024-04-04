@echo off
:;# MagickStack - Kevin M Henderson - 2023
:;set() { eval $1; }

:;# <---- START VARIABLES TO CHANGE---->
set WIDTH=2592
set HEIGHT=1944
set STACK_VERTICAL=1
set FONT_SIZE=32
set FONT_GRAVITY=SouthEast 
set JPG_QUALITY=75
set DATE=%date%
set "RESIZE=%WIDTH%^"
:;# <---- END VARIABLES TO CHANGE---->

:<<BATCH
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

		if !COUNT! gtr 0 (
			pushd "%%f" && mkdir temp
			REM copies all images into 'temp'
			copy *.jpg temp\ 1>NUL 2>NUL
			copy *.jpeg temp\ 1>NUL 2>NUL

			pushd temp
			for %%i in (*.jpg) do (
				echo %%i
				if %STACK_VERTICAL% equ 1 (
					set "RESIZE=%WIDTH%"
				) else (
					set "RESIZE=%WIDTH%^"
				)
				
				magick convert "%%i" -auto-orient -resize %RESIZE% "%%i"
				magick convert "%%i" -undercolor "#ffffff28" -gravity %FONT_GRAVITY% -pointsize !FONT_SIZE! -fill black -annotate +0+0  "%%[exif:DateTimeOriginal]" "%%i"1>NUL 2>NUL
			)
			magick convert %ORIENTATION% * -auto-orient "..\%%f_%DATE%.png"
			magick convert -strip -interlace Plane -gaussian-blur 0.05 -quality %JPG_QUALITY%%% "..\%%f_%DATE%.png" "..\..\%%f_%DATE%.jpg"
			popd && rmdir /s /q temp && echo "hello" && echo %%f_%DATE%.jpg
		)
	)
	:;# <---- END WINDOWS CODE ---->

