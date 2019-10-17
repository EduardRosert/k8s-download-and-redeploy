#!/bin/sh

# NEEDS ENVIRONMENT VARIABLES:
# ---------------------------------
# export MODEL_NAME="icon-eu"
# export MODEL_FIELDS="t_2m tmax_2m clch"
# export MAX_TIME_STEP="24"
# export DOWNLOAD_BASE_PATH="/some-path"
# export TARGET_NAMESPACE="my-k8s-namespace"
# export LABEL_SELECTOR="app=myapp"

missingenv=0
if [ -z "$MODEL_NAME" ]; then
    echo "\$MODEL_NAME not set"
    missingenv=1
fi

if [ -z "$MODEL_FIELDS" ]; then
    echo "\$MODEL_FIELDS not set"
    missingenv=1
fi

if [ -z "$MAX_TIME_STEP" ]; then
    echo "\$MAX_TIME_STEP not set"
    missingenv=1
fi

if [ -z "$DOWNLOAD_BASE_PATH" ]; then
    echo "\$DOWNLOAD_BASE_PATH not set"
    missingenv=1
fi

if [ -z "$TARGET_NAMESPACE" ]; then
    echo "\$TARGET_NAMESPACE not set"
    missingenv=1
fi

if [ -z "$LABEL_SELECTOR" ]; then
    echo "\$LABEL_SELECTOR not set"
    missingenv=1
fi

if [ "$missingenv" = "1" ]; then
    echo "ERROR: Missing environment variables found."
    exit 1
fi

# get the latest model timestamp
timestamp=$(python opendata-downloader.py --model $MODEL_NAME --get-latest-timestamp)

# get
abspath=$(cd "$DOWNLOAD_BASE_PATH"; pwd)
targetdir="$abspath/$timestamp"
latestdir="$abspath/latest"

if [ -d "$targetdir" ]; then
    echo "No new data available. Latest data time stamp: '$timestamp'. Exiting. "
    exit 0
fi

echo "New data available. Latest data time stamp: $timestamp"
mkdir -p $targetdir

echo "Downloading new model data..."
python opendata-downloader.py --model $MODEL_NAME --single-level-fields $MODEL_FIELDS --max-time-step $MAX_TIME_STEP --directory $targetdir -v

# overwrite latest file with the current timestamp
echo $timestamp >latest.txt

# update the 'latest' symbolic link
rm latestdir
ln -s $targetdir $latestdir

#restart containers
echo "Redeploying app ..."
python controller.py --namespace $TARGET_NAMESPACE --label-selector $LABEL_SELECTOR --trigger-smart-rollout

# Cleanup
echo "Deleting old directories..."
find $abspath -mindepth 1 -type d -not -path $latestdir -not -path $targetdir -exec echo {} \;
find $abspath -mindepth 1 -type d -not -path $latestdir -not -path $targetdir -delete

echo "All done!"