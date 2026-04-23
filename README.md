This repository contains the analysis pipeline, filtered VCF files, and diagnostic results.

Important Note on Large Files:
Due to storage limitations on GitHub, large genomic files have been excluded from this repository. These include:

Raw and aligned sequencing data (BAM/BAI files).

Reference genome sequences (FASTA and FAI).

Alignment indexes (Bowtie2 .bt2 files).

Access to Raw Data:
All intermediate and large-scale files are stored and organized for reproducibility on the course's UNIX server. They can be accessed by authorized personnel at the following location:

Server IP: 159.149.160.7

Path: ~/progetto/trio_[1-5]/

This setup ensures that the full bioinformatic workflow, from raw reads to final variant calls, can be audited and re-run in the original computing environmen
