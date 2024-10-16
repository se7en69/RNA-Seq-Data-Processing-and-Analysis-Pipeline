#!/bin/bash

# Redirect stdout (1) and stderr (2) to a log file
exec > Quantification_log.out 2>&1

# Usage function to display help for the script
usage() {
    echo "Usage: $0 -b bam_directory -r regions_bed -o output_directory [-t threads]"
    exit 1
}

# Default number of threads
THREADS=8

# Parse command-line arguments
while getopts ":b:r:o:t:" opt; do
    case $opt in
        b) BAM_DIR="$OPTARG"
        ;;
        r) REGIONS_BED="$OPTARG"
        ;;
        o) OUTPUT_DIR="$OPTARG"
        ;;
        t) THREADS="$OPTARG"
        ;;
        \?) echo "Invalid option -$OPTARG" >&2
            usage
        ;;
    esac
done

# Check if all required arguments are provided
if [ -z "$BAM_DIR" ] || [ -z "$REGIONS_BED" ] || [ -z "$OUTPUT_DIR" ]; then
    usage
fi

LOG_DIR="/home/bionerd/bedtools/logs"
mkdir -p "$OUTPUT_DIR" "$LOG_DIR"

# Check if Bedtools is installed
if ! command -v bedtools &> /dev/null; then
    echo "Bedtools could not be found. Please install it and try again."
    exit 1
fi

# Check if the input directory contains BAM files
if [ -z "$(ls -A "$BAM_DIR"/*.bam 2>/dev/null)" ]; then
    echo "No BAM files found in the input directory: $BAM_DIR"
    exit 1
fi

# Check if the BED file exists
if [ ! -f "$REGIONS_BED" ]; then
    echo "Regions BED file not found: $REGIONS_BED"
    exit 1
fi

echo "Running Bedtools coverage on BAM files..."

# Loop through all BAM files and calculate coverage
for BAM_FILE in "$BAM_DIR"/*.bam; do
    BASENAME=$(basename "$BAM_FILE" .bam)

    echo "Calculating coverage for $BASENAME..."

    # Run Bedtools coverage and capture logs
    bedtools coverage -a "$REGIONS_BED" -b "$BAM_FILE" > "$OUTPUT_DIR/${BASENAME}_coverage.txt" 2> "$LOG_DIR/${BASENAME}_bedtools.log"

    # Check if Bedtools ran successfully
    if [[ $? -ne 0 ]]; then
        echo "Error: Bedtools coverage failed for $BASENAME. Check $LOG_DIR/${BASENAME}_bedtools.log for details." >> "$LOG_DIR/error.log"
    else
        echo "Coverage calculated successfully for $BASENAME."
    fi
done

echo "Quantification completed."
