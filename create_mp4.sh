#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
  echo "Usage: $0 <mode> <input> [framerate]"
  echo "Modes:"
  echo "  file   - Provide a file containing a list of JPGs"
  echo "  folder - Provide a folder containing JPGs"
  echo "Optional:"
  echo "  framerate - Set output video framerate (allowed: 6, 12, 24; default: 24)"
  exit 1
fi

mode="$1"  # First argument specifies the mode (file or folder)
input="$2" # Second argument specifies the input (file path or folder path)

# Generate a date stamp for the output file
date_stamp=$(date +"%Y-%m-%d_%H-%M-%S")

# Set output directory
output_dir="output"
mkdir -p "$output_dir"

# Handle the 'file' mode
if [ "$mode" == "file" ]; then
  input_file="$input" # Use the provided file as the input list for ffmpeg
  base_name=$(basename "$input" .txt) # Extract the base name of the file
  output_file="${output_dir}/${base_name}_${date_stamp}.mp4" # Create the output file name

# Handle the 'folder' mode
elif [ "$mode" == "folder" ]; then
  input_file=$(mktemp) # Create a temporary file to store the list of JPGs
  for img in "$input"/*.jpg; do
    # Add each JPG file to the list with the required 'file' prefix
    echo "file '$(realpath "$img")'" >> "$input_file"
  done
  base_name=$(basename "$input") # Extract the base name of the folder
  output_file="${output_dir}/${base_name}_${date_stamp}.mp4" # Create the output file name

# Handle invalid modes
else
  echo "Invalid mode. Use 'file' or 'folder'."
  exit 1
fi

# Run ffmpeg to create an MP4 video from the list of JPGs
# Check for optional framerate argument (third argument)
framerate=24
if [ "$#" -ge 3 ]; then
  if [[ "$3" =~ ^(6|12|24)$ ]]; then
    framerate="$3"
  else
    echo "Invalid framerate. Allowed values: 6, 12, 24."
    exit 1
  fi
fi

ffmpeg -f concat -safe 0 -i "$input_file" -r "$framerate" -fps_mode vfr -pix_fmt yuv420p "$output_file"

# Clean up the temporary file if 'folder' mode was used
if [ "$mode" == "folder" ]; then
  rm "$input_file"
fi
