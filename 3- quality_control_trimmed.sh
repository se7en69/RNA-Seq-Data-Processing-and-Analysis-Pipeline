#!/bin/bash

# Redirect stdout (1) and stderr (2) to a log file
exec > TrimmedQualityControl_log.out 2>&1

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
        d) TRIMMED_FASTQ_DIR="$OPTARG"
        ;;
        o) TRIMMED_QC_DIR="$OPTARG"
        ;;
        t) THREADS="$OPTARG"
        ;;
        \?) echo "Invalid option -$OPTARG" >&2
            usage
        ;;
    esac
done

# Check if all required arguments are provided
if [ -z "$TRIMMED_FASTQ_DIR" ] || [ -z "$TRIMMED_QC_DIR" ]; then
    usage
fi

LOG_DIR="/home/bionerd/star/logs"
mkdir -p "$TRIMMED_QC_DIR" "$LOG_DIR"

# Check if FastQC is installed
if ! command -v fastqc &> /dev/null; then
    echo "FastQC could not be found. Please install it and try again."
    exit 1
fi

# Check if input directory contains FASTQ files
if [ -z "$(ls -A "$TRIMMED_FASTQ_DIR"/*.fastq.gz 2>/dev/null)" ]; then
    echo "No trimmed FASTQ files found in the input directory: $TRIMMED_FASTQ_DIR"
    exit 1
fi

echo "Running FastQC on trimmed FASTQ files..."

for TRIMMED_FASTQ_FILE in "$TRIMMED_FASTQ_DIR"/*.fastq.gz; do
    BASENAME=$(basename "$TRIMMED_FASTQ_FILE" .fastq.gz)

    echo "Processing $TRIMMED_FASTQ_FILE..."
    fastqc -t $THREADS -o "$TRIMMED_QC_DIR" "$TRIMMED_FASTQ_FILE" > "$LOG_DIR/${BASENAME}_fastqc_trimmed.log" 2>&1

    # Check if FastQC ran successfully
    if [[ $? -ne 0 ]]; then
        echo "Error: FastQC failed for $TRIMMED_FASTQ_FILE" >> "$LOG_DIR/error.log"
    fi
done

echo "Quality control on trimmed data completed."
