#!/bin/bash

bucket_name="your-bucket-name"
path="your-folder-path"
date_to_delete="2023-06-01"  # Specify the specific date you want to delete files from
prefix="file-prefix"  # Specify the prefix of the files you want to delete

# Get the list of files in the specified path with the specified prefix
files=$(aws s3api list-objects --bucket "$bucket_name" --prefix "$path" --output json --query "Contents[?LastModified>='$date_to_delete' && starts_with(Key, '$prefix')].Key")

# Sort the files by the LastModified date in descending order
sorted_files=($(echo "$files" | jq -r 'sort_by(.LastModified) | reverse[]'))

# Keep the latest file and delete the rest
latest_file="${sorted_files[0]}"
for file in "${sorted_files[@]:1}"
do
    if [[ "$file" != "$latest_file" ]]; then
        echo "Deleting $file"
        aws s3api delete-object --bucket "$bucket_name" --key "$file"
    fi
done
