#!/bin/bash

# Redirect stdout (1) and stderr (2) to a log file
exec > Trimming_log.out 2>&1

# Usage function to display help for the script
usage() {
    echo "Usage: $0 -d input_directory -o output_directory -q qc_directory [-t threads]"
    exit 1
}

# Default number of threads
THREADS=8

# Parse command-line arguments
while getopts ":d:o:q:t:" opt; do
    case $opt in
        d) DOWNSAMPLED_FASTQ_DIR="$OPTARG"
        ;;
        o) TRIMMED_FASTQ_DIR="$OPTARG"
        ;;
        q) QC_DIR="$OPTARG"
        ;;
        t) THREADS="$OPTARG"
        ;;
        \?) echo "Invalid option -$OPTARG" >&2
            usage
        ;;
    esac
done

# Check if all required arguments are provided
if [ -z "$DOWNSAMPLED_FASTQ_DIR" ] || [ -z "$TRIMMED_FASTQ_DIR" ] || [ -z "$QC_DIR" ]; then
    usage
fi

LOG_DIR="/home/bionerd/star/logs"
mkdir -p "$TRIMMED_FASTQ_DIR" "$QC_DIR" "$LOG_DIR"

# Check if fastp is installed
if ! command -v fastp &> /dev/null; then
    echo "fastp could not be found. Please install it and try again."
    exit 1
fi

# Check if input directory contains any downsampled FASTQ files
if [ -z "$(ls -A "$DOWNSAMPLED_FASTQ_DIR"/*_R1_downsampled.fastq.gz 2>/dev/null)" ]; then
    echo "No downsampled FASTQ files found in the input directory: $DOWNSAMPLED_FASTQ_DIR"
    exit 1
fi

echo "Trimming adapters and low-quality bases with fastp..."

for FASTQ_FILE in "$DOWNSAMPLED_FASTQ_DIR"/*_R1_downsampled.fastq.gz; do
    BASENAME=$(basename "$FASTQ_FILE" _R1_downsampled.fastq.gz)
    FASTQ_FILE_R2="${DOWNSAMPLED_FASTQ_DIR}/${BASENAME}_R2_downsampled.fastq.gz"

    if [[ -f "$FASTQ_FILE" && -f "$FASTQ_FILE_R2" ]]; then
        echo "Processing $BASENAME..."

        # Run fastp and log output
        fastp -i "$FASTQ_FILE" -I "$FASTQ_FILE_R2" \
              -o "$TRIMMED_FASTQ_DIR/${BASENAME}_R1_trimmed.fastq.gz" \
              -O "$TRIMMED_FASTQ_DIR/${BASENAME}_R2_trimmed.fastq.gz" \
              -h "$QC_DIR/${BASENAME}_fastp.html" \
              -j "$QC_DIR/${BASENAME}_fastp.json" \
              -w $THREADS --detect_adapter_for_pe \
              --cut_front --cut_tail --cut_window_size 4 --cut_mean_quality 20 \
              --length_required 30 \
              > "$LOG_DIR/${BASENAME}_fastp.log" 2>&1

        # Check exit status and log if fastp failed
        if [[ $? -ne 0 ]]; then
            echo "Error: fastp failed for $BASENAME. Check $LOG_DIR/${BASENAME}_fastp.log for details." >> "$LOG_DIR/error.log"
        fi
    else
        echo "Error: Missing paired files for $BASENAME" >> "$LOG_DIR/error.log"
    fi
done

echo "Trimming completed."
