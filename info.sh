#!/bin/bash

PROJECT_ROOT="."

OUTPUT_FILE="info.txt"

MAX_SIZE=1000000

# Counters
total_files=0
included_files=0
skipped_files=0
included_file_list=""
skipped_file_list=""

# Log files content
log_file_processing() {
    local file_path="$1"
    local file_name=$(basename "$file_path")
    local file_size=$(stat -f%z "$file_path")
    ((total_files++))
    if [[ $file_size -le $MAX_SIZE ]]; then
        ((included_files++))
        included_file_list="$included_file_list$file_name"$'\n'
        echo -e "\n\n********** File: $file_name **********\n" >> "$OUTPUT_FILE"
        cat "$file_path" >> "$OUTPUT_FILE"
        echo >> "$OUTPUT_FILE"
    else
        ((skipped_files++))
        skipped_file_list="$skipped_file_list$file_name"$'\n'
    fi
}

# Write the tree structure to the output file
echo "Project Directory Structure" > "$OUTPUT_FILE"
tree "$PROJECT_ROOT" --noreport --filelimit 20 >> "$OUTPUT_FILE"
echo >> "$OUTPUT_FILE"

# Append file contents to the output file
echo "File Contents" >> "$OUTPUT_FILE"

# Include all files except hidden, media, .txt files, node_modules, .svg files, and specific css files
for file in $(find "$PROJECT_ROOT" -type f ! -path '*/\.*' ! -path '*/node_modules/*' ! -name '*.svg' ! -name 'custom.css' ! -name 'custom.css.map' ! -name 'style.css' ! -name 'package-lock.json' | grep -Ev '\.(jpg|jpeg|png|gif|pdf|mp3|mp4|avi|txt)$'); do
    log_file_processing "$file"
done

# List skipped files that are in the tree but not in the included files list
tree_files=$(tree "$PROJECT_ROOT" --noreport --filelimit 20 -f -fi)
skipped_tree_files=""
for file in $tree_files; do
    file_name=$(basename "$file")
    if [[ "$included_file_list" != *"$file_name"* ]]; then
        if [ ! -d "$file" ]; then
            skipped_tree_files="$skipped_tree_files$file_name"$'\n'
        fi
    fi
done

# Count the total number of files in the tree (excluding directories)
count_total_files=$(find "$PROJECT_ROOT" -type f ! -path '*/\.*' | wc -l)

# Count the number of hidden, media, .txt files, node_modules, .svg files, and specific css files in the tree
count_hidden_media_txt_files=$(find "$PROJECT_ROOT" -type f ! -path '*/\.*' -name '*.jpg' -o -name '*.jpeg' -o -name '*.png' -o -name '*.gif' -o -name '*.pdf' -o -name '*.mp3' -o -name '*.mp4' -o -name '*.avi' -o -name '*.txt' -o -path '*/node_modules/*' -o -name '*.svg' -o -name 'custom.css' -o -name 'custom.css.map' -o -name 'style.css' | wc -l)

# Calculate the count of included and skipped files
count_included_files=$((count_total_files - count_hidden_media_txt_files))
count_skipped_files=$count_hidden_media_txt_files

# Print summary as a table
echo -e "Script execution completed."
echo -e "--------------------------------------------"
echo -e "| Total files   | Included   | Skipped   |"
echo -e "--------------------------------------------"
printf "| %-13s | %-10s | %-8s |\n" "$count_total_files" "$count_included_files" "$count_skipped_files"
echo -e "--------------------------------------------"
echo -e "\nIncluded Files:"
echo -e "$included_file_list"
echo -e "Skipped Files:"
echo -e "$skipped_tree_files"
