# RNA-Seq Data Processing and Analysis Pipeline

This project provides a comprehensive and modular RNA-Seq data processing pipeline, automating quality control, read trimming, alignment, and coverage quantification. The pipeline ensures efficient, reproducible RNA-Seq analysis using popular bioinformatics tools, with detailed logging and reporting at every stage.

---

## 🚀 **Features**  
- **Automated Quality Control**: Pre- and post-trimming checks using FastQC with compiled MultiQC reports.  
- **Read Trimming**: Cleans raw reads by removing low-quality bases and adapters using `fastp`.  
- **Alignment**: Aligns cleaned reads to the reference genome with the STAR aligner, producing BAM files.  
- **Coverage Quantification**: Measures coverage across defined regions using `bedtools`.  
- **Detailed Logs and Error Handling**: Each script generates logs, ensuring easy debugging and tracking.  
- **Modular Design**: Each step can be run independently, supporting flexible workflows.

---

## 🛠️ **Tools and Technologies Used**  
- **FastQC**: For quality control of raw and trimmed reads.  
- **fastp**: Trimming low-quality regions and adapters.  
- **STAR**: Alignment of RNA-Seq reads to the reference genome.  
- **bedtools**: For calculating coverage over specific regions.  
- **MultiQC**: Compiling QC reports into a single summary.  
- **Bash scripting**: For automation of tasks across the pipeline.

---

## 📂 **Pipeline Overview**

1. **Quality Control of Raw Reads**  
   - Run FastQC on the input FASTQ files to assess initial quality.  
   - Example command:  
     ```bash
     ./1-quality_control.sh -d /path/to/raw_fastq/ -o /path/to/qc_reports/ -t 8
     ```
   
2. **Read Trimming**  
   - Use `fastp` to remove adapters and low-quality bases.  
   - Example command:  
     ```bash
     ./2-trimming_reads.sh -d /path/to/downsampled_fastq/ -o /path/to/trimmed_fastq/ -q /path/to/qc/ -t 8
     ```

3. **Quality Control on Trimmed Reads**  
   - Re-run FastQC on trimmed reads to ensure quality improvements.  
   - Example command:  
     ```bash
     ./3-quality_control_trimmed.sh -d /path/to/trimmed_fastq/ -o /path/to/trimmed_qc_reports/ -t 8
     ```

4. **Compile Quality Control Reports**  
   - Generate a single summary report using MultiQC.  
   - Example command:  
     ```bash
     ./4-compile_qc_reports.sh -d /path/to/trimmed_qc_reports/ -o /path/to/multiqc_report/
     ```

5. **Alignment to Reference Genome**  
   - Use STAR to align reads to a reference genome and generate BAM files.  
   - Example command:  
     ```bash
     ./5-alignment_star.sh -g /path/to/genome/ -i /path/to/trimmed_fastq/ -o /path/to/aligned_bam/ -a /path/to/annotation.gtf -t 8
     ```

6. **Coverage Quantification**  
   - Calculate coverage over specific genomic regions using bedtools.  
   - Example command:  
     ```bash
     ./6-quantification_coverage.sh -b /path/to/bam_files/ -r /path/to/regions.bed -o /path/to/coverage_output/ -t 8
     ```

---

## 💻 **How to Run the Pipeline**

### 1. **Clone the Repository**  
```bash
git clone https://github.com/your-username/rna-seq-pipeline.git
cd rna-seq-pipeline
```

### 2. **Install Dependencies**  
Make sure the following tools are installed and available in your `PATH`:  
- `FastQC`  
- `fastp`  
- `STAR`  
- `bedtools`  
- `MultiQC`  

Use `conda` or your package manager to install these tools if needed:
```bash
conda install -c bioconda fastqc fastp star bedtools multiqc
```

### 3. **Prepare Input Data**  
- Place your raw FASTQ files, reference genome, and annotation files in the appropriate directories.

### 4. **Execute the Pipeline**  
- Run each script in order or as needed (refer to the **Pipeline Overview** section).  
- Logs will be generated for each step to monitor progress and errors.

---

## ⚙️ **Pipeline Dependencies**  
- **Operating System**: Linux/macOS (Bash shell environment)  
- **Memory**: Recommended 16 GB RAM or more for large datasets  
- **CPU**: Multi-threading support (adjust `-t` argument for number of threads)

---

## 📝 **Logging and Troubleshooting**  
Each script generates detailed log files in the working directory:
- Example log: `QualityControl_log.out`
- Errors are captured separately for easier troubleshooting: `error.log`

---

## 📊 **Example Use Case**  
This pipeline can be used to process RNA-Seq data from experiments studying gene expression changes, alternative splicing, or differential expression between conditions.

---

## 🤝 **Contributing**  
Contributions are welcome! Please submit a pull request or open an issue if you find bugs or have feature requests.

---

## 📄 **License**  
This project is licensed under the MIT License – see the [LICENSE](LICENSE) file for details.

---

With this pipeline, you can ensure efficient and reproducible RNA-Seq data processing, enabling better insights from high-throughput sequencing data.
