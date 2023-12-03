# MagickStack

Uses ImageMagick to merge/stack multiple images horizontally or vertically to create a single image out of many.  Annotates image with timestamp and renames image with current date for a simpler upload to server.

## Usage

Put groups of images in separate folders.  When the script runs it will check each folder for images, if it finds more than 1 image in a folder, it combines them and moves the combined image into the root directory. 

## Examples

<img src="https://github.com/niveknosredneh/MagickStack/blob/main/Examples/Examples_2023-12-03.jpg" height="200" align="middle">


### Debian based:

Download stack.sh from this repo
```
sudo aptitude install imagemagick
chmod +x stack.sh
```
### Windows:
- Download stack.bat from this repo
- Download and install ImageMagick from https://imagemagick.org/script/download.php



## Authors

* **Kevin Matthew Henderson**

## Contributors

## License

This project is licensed under the MIT License - see the [LICENSE.md](https://github.com/niveknosredneh/PFSG/blob/master/LICENSE) file for details
