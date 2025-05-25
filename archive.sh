#!/bin/bash

FILE_SIZE=512M # Size of each chunk (<2GB, restricted by GitHub)
DATA_DIR="data"
TEMP_DIR="temp"
SCRIPT_PATH="$(dirname "$(realpath "$0")")"
CURRENT_GIT_REPO=$(cd $SCRIPT_PATH && git remote get-url origin 2>/dev/null | sed -E 's#(git@|https://)([^/:]+)[:/](.+)\.git#\3#')

ARCHIVE_TAR=$TEMP_DIR/data.tar.gz
ARCHIVE_CK_PATH=$TEMP_DIR/chunks

if [ -z "$CURRENT_GIT_REPO" ]; then
    echo "Error: Not a git repository or unable to determine the repository name."
    exit 1
fi

assert_at_root() {
    if [ "$(pwd)" != "$SCRIPT_PATH" ]; then
        echo "Error: Please run upload/download command at: $SCRIPT_PATH"
        exit 1
    fi
}

upload() {
    assert_at_root
    mkdir -p "$TEMP_DIR"
    if [ ! -f $ARCHIVE_TAR ]; then
        echo "Compressing data..."
        tar --exclude="README.md" -czf $ARCHIVE_TAR -C "$DATA_DIR" .
    else
        echo "Archive tar already exists, skipping compression."
    fi
    rm -rf $ARCHIVE_CK_PATH
    mkdir -p $ARCHIVE_CK_PATH
    echo "Splitting archive into 512MB chunks..."
    split -b $FILE_SIZE $ARCHIVE_TAR "$ARCHIVE_CK_PATH/data.tar.gz.part_"
    echo "Chunks created in $ARCHIVE_CK_PATH"
    file_list=$(ls $ARCHIVE_CK_PATH/data.tar.gz.part_* | tr '\n' ' ')
    python3 manage.py --repo $CURRENT_GIT_REPO upload --files $file_list --root $ARCHIVE_CK_PATH || {
        echo "Upload failed."
        exit 1
    }
    echo "Upload completed successfully."
    rm -rf $TEMP_DIR
    echo "Temporary files cleaned up."
    echo "Upload finished!"
}

download() {
    assert_at_root
    echo "Downloading data..."
    mkdir -p $ARCHIVE_CK_PATH
    python3 manage.py --repo $CURRENT_GIT_REPO download --root $ARCHIVE_CK_PATH || {
        echo "Download failed."
        exit 1
    }
    if [ -f "$ARCHIVE_CK_PATH/download_info" ]; then
        paths=$(cat "$ARCHIVE_CK_PATH/download_info")
    else
        echo "Error: $ARCHIVE_CK_PATH/download_info not found."
        exit 1
    fi
    echo "Combining chunks into a single archive..."
    cat $paths > $ARCHIVE_TAR
    echo "Extracting archive..."
    mkdir -p "$DATA_DIR"
    tar -xzf $ARCHIVE_TAR -C "$DATA_DIR"
    echo "Download and extraction completed successfully."
    rm -rf $TEMP_DIR
    echo "Temporary files cleaned up."
    echo "Download finished!"
}

case "$1" in
    upload)
        upload
        ;;
    download)
        download
        ;;
    link)
        if [ -z "$2" ]; then
            echo "Usage: $0 link <symlink_name>"
            exit 1
        fi
        ln -sfn "$SCRIPT_PATH/$DATA_DIR" "$2"
        echo "Symlink '$2' created, pointing to '$DATA_DIR'."
        ;;
    *)
        echo "Usage: $0 {upload|download|link <symlink_name>}"
        exit 1
        ;;
esac