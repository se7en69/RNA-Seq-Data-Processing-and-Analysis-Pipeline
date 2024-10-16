#!/bin/bash

# Redirect stdout (1) and stderr (2) to a log file
exec > Alignment_log.out 2>&1

# Usage function to display help for the script
usage() {
    echo "Usage: $0 -g genome_directory -i input_directory -o output_directory -a annotation_file [-t threads]"
    exit 1
}

# Default number of threads
THREADS=8

# Parse command-line arguments
while getopts ":g:i:o:a:t:" opt; do
    case $opt in
        g) GENOME_DIR="$OPTARG"
        ;;
        i) INPUT_DIR="$OPTARG"
        ;;
        o) OUTPUT_DIR="$OPTARG"
        ;;
        a) GTF_FILE="$OPTARG"
        ;;
        t) THREADS="$OPTARG"
        ;;
        \?) echo "Invalid option -$OPTARG" >&2
            usage
        ;;
    esac
done

# Check if all required arguments are provided
if [ -z "$GENOME_DIR" ] || [ -z "$INPUT_DIR" ] || [ -z "$OUTPUT_DIR" ] || [ -z "$GTF_FILE" ]; then
    usage
fi

LOG_DIR="/home/bionerd/star/logs"
mkdir -p "$OUTPUT_DIR" "$LOG_DIR"

# Check if STAR is installed
if ! command -v STAR &> /dev/null; then
    echo "STAR could not be found. Please install it and try again."
    exit 1
fi

# Check if genome directory exists and contains index files
if [ -z "$(ls -A "$GENOME_DIR"/*Genome 2>/dev/null)" ]; then
    echo "Genome index not found in $GENOME_DIR. Generating genome index..."

    # Check if genome FASTA files exist in the directory
    if [ -z "$(ls -A "$GENOME_DIR"/*.fa 2>/dev/null)" ]; then
        echo "No FASTA files found in genome directory: $GENOME_DIR"
        exit 1
    fi

    # Generate the genome index
    STAR --runThreadN $THREADS \
         --runMode genomeGenerate \
         --genomeDir "$GENOME_DIR" \
         --genomeFastaFiles "$GENOME_DIR"/*.fa \
         --sjdbGTFfile "$GTF_FILE" \
         --sjdbOverhang 100 \
         > "$LOG_DIR/genome_index.log" 2>&1

    if [[ $? -ne 0 ]]; then
        echo "Error: Genome indexing failed. Check $LOG_DIR/genome_index.log for details." >> "$LOG_DIR/error.log"
        exit 1
    else
        echo "Genome index generated successfully."
    fi
else
    echo "Genome index found in $GENOME_DIR. Skipping indexing..."
fi

# Check if input directory contains FASTQ files
if [ -z "$(ls -A "$INPUT_DIR"/*_R1_trimmed.fastq.gz 2>/dev/null)" ]; then
    echo "No trimmed FASTQ files found in the input directory: $INPUT_DIR"
    exit 1
fi

echo "Running STAR alignment using genome index..."

for FASTQ_FILE in "$INPUT_DIR"/*_R1_trimmed.fastq.gz; do
    BASENAME=$(basename "$FASTQ_FILE" _R1_trimmed.fastq.gz)
    FASTQ_FILE_R2="${INPUT_DIR}/${BASENAME}_R2_trimmed.fastq.gz"

    if [[ -f "$FASTQ_FILE" && -f "$FASTQ_FILE_R2" ]]; then
        echo "Aligning $BASENAME..."

        # Run STAR and capture logs
        STAR --runThreadN $THREADS \
             --genomeDir "$GENOME_DIR" \
             --readFilesIn "$FASTQ_FILE" "$FASTQ_FILE_R2" \
             --readFilesCommand zcat \
             --outFileNamePrefix "$OUTPUT_DIR/${BASENAME}_" \
             --outSAMtype BAM SortedByCoordinate \
             --outSAMunmapped Within \
             --outFilterType BySJout \
             --outFilterMultimapNmax 20 \
             --alignSJoverhangMin 8 \
             --alignSJDBoverhangMin 1 \
             --outFilterMismatchNmax 999 \
             --outFilterMismatchNoverReadLmax 0.04 \
             --alignIntronMin 20 \
             --alignIntronMax 1000000 \
             --alignMatesGapMax 1000000 \
             > "$LOG_DIR/${BASENAME}_star.log" 2>&1

        # Check if STAR ran successfully
        if [[ $? -ne 0 ]]; then
            echo "Error: STAR alignment failed for $BASENAME. Check $LOG_DIR/${BASENAME}_star.log for details." >> "$LOG_DIR/error.log"
        else
            echo "STAR alignment completed for $BASENAME."
        fi
    else
        echo "Error: Missing paired file for $BASENAME" >> "$LOG_DIR/error.log"
    fi
done

echo "Alignment completed."