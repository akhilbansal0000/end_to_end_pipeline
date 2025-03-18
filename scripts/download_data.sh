#!/bin/bash

echo "Starting Spark first..."
/scripts/start-spark.sh &

echo "Spark started. Initiating data downloads..."

# ✅ Ensure "data/document" is copied to "/data/" (inside the volume) if missing
echo "Checking if /data/document exists..."
if [ ! -d "/data/document" ]; then
    echo "Copying missing document folder from /data/document..."
    cp -r /data/document /data/
    echo "Document folder copied successfully."
else
    echo "Document folder already exists in /data/."
fi

datasets=(
  "ml-32m"
  "ml-latest-small"
  "ml-latest"
  "ml-100k"
  "ml-1m"
  "ml-10m"
  "ml-20m"
  "ml-25m"
)

for dataset_path in "${datasets[@]}"; do
  dataset=$(basename "$dataset_path")
  dir_path="/data/$dataset"
  zip_url="https://files.grouplens.org/datasets/movielens/${dataset_path}.zip"
  zip_file="$dataset.zip"

  if [ ! -d "$dir_path" ]; then
    echo "Downloading and extracting $dataset..."
    if wget -q "$zip_url"; then
      if unzip -qo "$zip_file" -d /data/; then
        echo "$dataset downloaded and extracted successfully."
        rm "$zip_file"
      else
        echo "Error: Failed to unzip $zip_file. Checking file integrity..."
        rm -f "$zip_file"  # Remove corrupted zip file
      fi
    else
      echo "Error: Failed to download $zip_url."
    fi
  else
    echo "$dataset already exists in $dir_path."
  fi
done

echo "Data downloads completed. Keeping the container alive..."
exec tail -f /dev/null
