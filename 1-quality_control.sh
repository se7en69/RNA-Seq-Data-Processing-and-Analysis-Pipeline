#!/bin/bash

# Redirect stdout (1) and stderr (2) to a log file
exec > QualityControl_log.out 2>&1

# Usage function to display help for the script
usage() {
    echo "Usage: $0 -d input_directory -o output_directory [-t threads]"
    exit 1
}

# Default number of threads
THREADS=8

# Parse command-line arguments
while getopts ":d:o:t:" opt; do
    case $opt in
        d) FASTQ_DIR="$OPTARG"
        ;;
        o) QC_DIR="$OPTARG"
        ;;
        t) THREADS="$OPTARG"
        ;;
        \?) echo "Invalid option -$OPTARG" >&2
            usage
        ;;
    esac
done

# Check if all required arguments are provided
if [ -z "$FASTQ_DIR" ] || [ -z "$QC_DIR" ]; then
    usage
fi

# Check if FastQC is installed
if ! command -v fastqc &> /dev/null; then
    echo "FastQC could not be found. Please install it and try again."
    exit 1
fi

# Check if input directory contains FASTQ files
if [ -z "$(ls -A "$FASTQ_DIR"/*.fastq.gz 2>/dev/null)" ]; then
    echo "No FASTQ files found in the input directory: $FASTQ_DIR"
    exit 1
fi

# Create output directory if it doesn't exist
mkdir -p "$QC_DIR"

echo "Running FastQC on raw FASTQ files..."
for FASTQ_FILE in "$FASTQ_DIR"/*.fastq.gz; do
    echo "Processing $FASTQ_FILE..."
    fastqc -t "$THREADS" -o "$QC_DIR" "$FASTQ_FILE" 2>> QualityControl_error.log
    if [ $? -ne 0 ]; then
        echo "FastQC failed for $FASTQ_FILE. Check QualityControl_error.log for details."
    fi
done

echo "Quality control completed."
