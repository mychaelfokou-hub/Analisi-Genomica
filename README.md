# Genomics-FamilyTrios

## Project Background
[cite_start]This repository contains the final project for the **Genomics and Transcriptomics** course, part of the Master's degree in **Bioinformatics for Computational Genomics** at the University of Milan (UniMi) and Politecnico di Milano (Polimi)[cite: 1]. [cite_start]The course aims to provide a solid foundation in modern genomic and transcriptomic analysis using **Unix**-based environments and industry-standard bioinformatic tools for processing nucleic acid sequencing data[cite: 3].

## Project Overview
[cite_start]The primary objective of this study is to implement a realistic diagnostic workflow for identifying rare genetic disorders using simulated **Trio-based Exome Sequencing** data[cite: 2]. [cite_start]The analysis focuses on identifying causal variants by applying inheritance-based filtering models (Autosomal Recessive, Autosomal Dominant *de novo*, or Inherited)[cite: 25, 26].

### Technical Details:
* [cite_start]**Genomic Context**: Exome sequencing focused exclusively on **Chromosome 20** (GRCh38 reference)[cite: 18].
* [cite_start]**Datasets**: Simulated data derived from real genotypes provided by the 1000 Genomes Project[cite: 5].
* [cite_start]**Workflow**: The pipeline covers the entire process from raw data quality control (FastQC) and alignment (Bowtie2) to variant calling (Freebayes), clinical annotation (VEP), and diagnostic interpretation[cite: 3, 50].
* [cite_start]**Reproducibility**: All intermediate files, logs, and final variants are organized to ensure the analysis is fully reproducible[cite: 68, 69].

## Repository Structure
* **`pipeline_trio_x.sh`**: The original Bash script documenting the complete bioinformatic pipeline.
* [cite_start]**`trio_1/` to `trio_5/`**: Directories containing the filtered VCF files and quality reports for each assigned family case[cite: 22].
* **`README.md`**: This file, providing an overview of the technical approach.

> [cite_start]**Note**: For the detailed clinical interpretation, UCSC Genome Browser visualizations, and the final diagnosis for each trio, please refer to the **Final PDF Report** submitted[cite: 52, 61].

## Author
This work was conducted and implemented by **Mychael Fokou**.
