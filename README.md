# Timelapse MP4 Creation Script

This script creates an MP4 timelapse video from a list of JPG images, either from a file or a folder.

## Usage

```bash
./create_mp4.sh <mode> <input> [framerate]
```

- `<mode>`:  
  - `file`   — Use a text file containing a list of JPGs (one per line, ffmpeg concat format).
  - `folder` — Use a folder containing JPG images.

- `<input>`:  
  - For `file` mode: path to the text file.
  - For `folder` mode: path to the folder with JPGs.

- `[framerate]` (optional):  
  - Output video framerate. Allowed values: `6`, `12`, `24`. Default: `24`.

## Examples

**From a folder of images:**
```bash
./create_mp4.sh folder /path/to/images 12
```

**From a file list:**
```bash
./create_mp4.sh file /path/to/list.txt 24
```

## Output

- The resulting MP4 will be saved in the `output/` directory, with a timestamp in the filename.

## Requirements

- [ffmpeg](https://ffmpeg.org/)  
- For advanced filtering (e.g., skipping dark images): [ImageMagick](https://imagemagick.org/) and `bc` (optional, see below)

## Skipping Dark Images (Optional)

To skip dark images in `folder` mode, you can modify the script to use ImageMagick to check brightness before including each image.  
See the script comments for an example.

## Notes

- The script will create the `output/` directory if it does not exist.
- Only `.jpg` files are processed in `folder` mode.
- The script checks for valid framerate values and prints usage instructions if arguments are