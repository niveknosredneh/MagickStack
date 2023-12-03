@echo off
setlocal enabledelayedexpansion

REM MagickStack - Kevin M Henderson 2023
set WIDTH=1920
set HEIGHT=1920
set STACK_VERTICAL=0
set /a FONT_SIZE=HEIGHT/45
set FONT_GRAVITY=SouthEast
set JPG_QUALITY=75
set "DATE=%DATE:~-4%-%DATE:~3,2%-%DATE:~0,2%"

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
        copy "*.jpg" "*.jpeg" temp\

        pushd temp
        for %%i in (*) do (
            echo %%f/%%i
            
            if %STACK_VERTICAL% equ 1 (
                convert.exe "%%i" -auto-orient -resize %WIDTH% "%%i"
            ) else (
                convert.exe "%%i" -auto-orient -resize x%HEIGHT% "%%i"
            )
            
            convert.exe "%%i" -gravity %FONT_GRAVITY% -pointsize !FONT_SIZE! -fill black -annotate +2+2 "%%[exif:DateTimeOriginal]" "%%i"
            convert.exe "%%i" -gravity %FONT_GRAVITY% -pointsize !FONT_SIZE! -fill white -annotate +2+!FONT_SIZE! "%%[exif:DateTimeOriginal]" "%%i"
        )

        convert.exe %ORIENTATION% * -auto-orient "%%f_%DATE%.png"
        convert.exe -strip -interlace Plane -gaussian-blur 0.05 -quality %JPG_QUALITY%%% "%%f_%DATE%.png" "%%f_%DATE%.jpg"
        move "%%f_%DATE%.jpg" ..\..\

        echo "~~%%f_%DATE%.jpg~~"
        popd
        rmdir /s /q temp
        popd
    )
)
