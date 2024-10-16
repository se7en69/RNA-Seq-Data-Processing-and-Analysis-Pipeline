#!/bin/bash

# Redirect stdout (1) and stderr (2) to a log file
exec > CompileQCReports_log.out 2>&1

# Usage function to display help for the script
usage() {
    echo "Usage: $0 -d qc_directory -o output_directory"
    exit 1
}

# Parse command-line arguments
while getopts ":d:o:" opt; do
    case $opt in
        d) TRIMMED_QC_DIR="$OPTARG"
        ;;
        o) QC_REPORT_DIR="$OPTARG"
        ;;
        \?) echo "Invalid option -$OPTARG" >&2
            usage
        ;;
    esac
done

# Check if all required arguments are provided
if [ -z "$TRIMMED_QC_DIR" ] || [ -z "$QC_REPORT_DIR" ]; then
    usage
fi

LOG_DIR="/home/bionerd/star/logs"
mkdir -p "$QC_REPORT_DIR" "$LOG_DIR"

# Check if MultiQC is installed
if ! command -v multiqc &> /dev/null; then
    echo "MultiQC could not be found. Please install it and try again."
    exit 1
fi

# Check if QC directory contains any data
if [ -z "$(ls -A "$TRIMMED_QC_DIR" 2>/dev/null)" ]; then
    echo "No files found in the QC directory: $TRIMMED_QC_DIR"
    exit 1
fi

echo "Compiling QC reports with MultiQC..."

# Run MultiQC and log output and errors
multiqc "$TRIMMED_QC_DIR" -o "$QC_REPORT_DIR" > "$LOG_DIR/multiqc.log" 2>&1

if [[ $? -ne 0 ]]; then
    echo "Error: MultiQC failed to compile reports" >> "$LOG_DIR/error.log"
else
    echo "QC reports compiled successfully. Output is available in $QC_REPORT_DIR."
fi
