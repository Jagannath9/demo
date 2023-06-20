#!/bin/bash

bucket_name="your-bucket-name"
path="your-folder-path"
start_date="2023-06-01"  # Specify the start date of the range
end_date="2023-06-30"  # Specify the end date of the range
prefix="file-prefix"  # Specify the prefix of the files you want to delete

# Get the list of files in the specified path with the specified prefix within the date range
files=$(aws s3api list-objects --bucket "$bucket_name" --prefix "$path" --output json --query "Contents[?LastModified>='$start_date' && LastModified<='$end_date' && starts_with(Key, '$prefix')].Key")

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
