#!/bin/bash

# Script to find or move dark JPG images based on brightness.
# Usage:
#   ./find_dark_images.sh display <input> [debug]
#   ./find_dark_images.sh move <input> [debug]
# <input> can be a folder or a file (list of images, one per line).

set -e

if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
  echo "Usage: $0 <mode> <input> [debug]"
  echo "Modes:"
  echo "  display - List dark images"
  echo "  move    - Move dark images to subfolder 'to_dark_to_be_deleted'"
  echo "Input:"
  echo "  Folder path or file with list of image paths"
  echo "Optional:"
  echo "  debug   - Print brightness for each image"
  exit 1
fi

mode="$1"
input="$2"
debug=0
if [ "$#" -eq 3 ] && [ "$3" == "debug" ]; then
  debug=1
fi
brightness_threshold=0.25  # Adjust as needed (0.0 - 1.0)

# Build list of files
if [ -d "$input" ]; then
  mapfile -t files < <(find "$input" -maxdepth 1 -iname '*.jpg' | sort)
elif [ -f "$input" ]; then
  mapfile -t files < "$input"
else
  echo "Input must be a folder or a file containing image paths."
  exit 1
fi

if [ "${#files[@]}" -eq 0 ]; then
  echo "No JPG files found."
  exit 0
fi

if [ "$mode" == "move" ]; then
  dark_dir="$(dirname "${files[0]}")/to_dark_to_be_deleted"
  mkdir -p "$dark_dir"
fi

total=${#files[@]}
count=0

for img in "${files[@]}"; do
  count=$((count + 1))
  echo -ne "Processing $count of $total\r"
  if [ ! -f "$img" ]; then continue; fi
  mean_brightness=$(convert "$img" -colorspace Gray -format "%[fx:mean]" info:)
  if [ "$debug" -eq 1 ]; then
    echo "$img brightness: $mean_brightness"
  fi
  if (( $(echo "$mean_brightness < $brightness_threshold" | bc -l) )); then
    if [ "$mode" == "display" ]; then
      echo "$img"
    elif [ "$mode" == "move" ]; then
      mv "$img" "$dark_dir/"
      echo "Moved $img to $dark_dir/"
    else
      echo "Invalid mode: $mode"
      exit 1
    fi
  fi
done

echo -e "\nDone."