# **SUMMER**
[![Run with Docker](https://img.shields.io/badge/Run%20with-Docker-blue?logo=docker)](https://www.docker.com/) ![Bioinformatics Pipeline](https://img.shields.io/badge/Bioinformatics-Analysis%20Pipeline-brightgreen) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT) 
<div align="center">
  <img src="https://github.com/carolhuaxia/summer/blob/main/SUMMER-Title.png" alt="SUMMER Pipeline Workflow" width="500 length="800" height="200">
</div>

**SUMMER** is an integrated pipeline for clinical variation detection via nanopore sequencing raw reads. It strongly simplifies the process of detecting and annotating possible pathogenic structural variations, mobile elements, etc.

## **Overview**
Long-read sequencing has experienced significant growth in recent years, particularly for addressing **complex genetic variations** in humans. The **SUMMER** pipeline incorporates state-of-the-art softwares for Oxford Nanopore Technologies (ONT) long-read sequencing, providing a streamlined workflow for clinical and research insights.

All the tools integrated in **SUMMER** are encapsulated in a Docker container, allowing users to run the pipeline with ease and flexibility. Additionally, users can modify the pipeline to incorporate custom functionalities.

## **Key Features**
- **Structural Variation Detection**: Identify large-scale genomic rearrangements using a combination of **Sniffles2, CuteSV, SVIM with combiSV as refiner**.
- **Mobile Element Detection**: Detect transposable elements in the genome via **TLDR**.
- **SNV and Indel Detection**: Find SNV and small Indels in the genome via **Clair3**.
- **Tandem Repeat Detection**: Detect tandem repeats using **straglr**.
- **Customizable**: Users can sperate each step of **SUMMER** to meet specific needs using Docker.

## **Pipeline Workflow**
![Pipeline Interface](https://github.com/carolhuaxia/summer/assets/54387977/81f5db90-176c-4d6a-a81d-7690a9f292f5)

The pipeline consists of several key stages, each designed to handle specific tasks in long-read sequencing:

1. **Preprocessing**: Quality control and read filtering with **PanDepth**.
2. **Alignment**: Mapping long-read sequences to the reference genome.
3. **Variation Detection**: Identifying structural variations, mobile elements, and mutations.
4. **Annotation**: Annotating the detected variations to provide clinical insights.

## **Quick Start**
Detail usage can be seen in the [full official documentation](https://pku-edu.gitbook.io/summer-pipeline-for-long-read-sequencing/)

To get started, pull the container using the following command:
```bash
# docker pull the preinstalled and precompiled software
docker pull chuhongyuan/summer:latest

# download SUMMER workflow from github
download SUMMER at https://github.com/carolhuaxia/summer
chmod +x PATH_TO_SUMMER/summer

# get help (you can view full help page in **official documentation** above)
python PATH_TO_SUMMER/summer -h
```
Basic usage:
```bash
summer --MODE -i <INPUTDIR> -s <SAMPLEFILE> -o <OUTDIR> -rd <REFDIR> -r <REFFILE> -x {male,female}
```
For example:
```bash
summer --align -i /data/project/ -s sample.fastq -o /data/output/ -rd /data/refseqdir -r hg38.fa -x male
```
You may also able to enter a container in an interactive way (to view your intermediate files, to download them,etc) :
```bash
docker run -it chuhongyuan/summer:latest
```


# Singularity and SnakeMake
### If you are using hpc or without root permissions, Singularity deployments are more suited 
```bash
#pull summer image from online:
singularity pull summer.sif docker://chuhongyuan/summer:latest
#Minimap alignment
singularity run {summersifdir}/summer.sif /opt/minimap2/minimap2 -ax map-ont --secondary=no --MD -t {number of thread} {refdir/refseq} {inputdir/inputfq.gz} -o {outputdir/output.sam}
#samtools sort and index
singularity run {summersifdir}/summer.sif opt/conda/bin/samtools view -@ {number of thread} -b {inputdir/input.sam} -o {outdir/output.bam}
singularity run {summersifdir}/summer.sif /opt/conda/bin/samtools sort -@ {number of thread} {inputdir/output.bam} -o {outdir/output_sorted.bam}
singularity run {summersifdir}/summer.sif /opt/conda/bin/samtools index -@ {number of thread} {inputdir/input_sorted.bam}
#pandepth
singularity run {summersifdir}/summer.sif /opt/PanDepth/pandepth -i {inputdir/input_sorted.bam} -o {outdir} -t {number of thread}
#call SVs
singularity run {summersifdir}/summer.sif /opt/conda/envs/cutesv/bin/cuteSV --max_cluster_bias_INS 100 --diff_ratio_merging_INS 0.3 --max_cluster_bias_DEL 100 --diff_ratio_merging_DEL 0.3 --genotype -q 20 -r 50 -L 50000000 -t {number of thread} -s 2 {inputdir/input_sorted.bam} {refdir/refseq} {outdir} {workdir}
singularity run {summersifdir}/summer.sif conda run -n svim svim alignment --min_sv_size 50 {outdir} {inputdir/input_sorted.bam} {refdir/refseq}
singularity run {summersifdir}/summer.sif conda run -n sniffles sniffles --threads {number of thread} --input {inputdir/input_sorted.bam} --vcf {outdir/sample_sniffles2.vcf} --reference {refdir/refseq}
#combisv
singularity run {summersifdir}/summer.sif perl /opt/combiSV/combiSV2.2.pl -cutesv {cutesvvcfdir/cutesvout.vcf} -svim {svimvcfdir/signatures/all.vcf} -sniffles {snifflesvcfdir/sample_sniffles2.vcf} -o {outdir/combisv.vcf}
#call STRs using straglr
singularity run {summersifdir}/summer.sif conda run -n straglr python /opt/conda/envs/straglr/bin/straglr-genotype --loci /opt/conda/envs/straglr/bin/straglr-master/repeat-annotation/hg38/merge.bed --sample sample --vcf {outdir/outdir.vcf} --sex {male OR female} {inputdir/input_sorted.bam} {refdir/refseq}
#call MEIs using tldr
singularity run {summersifdir}/summer.sif conda run -n tldr /opt/tldr/tldr/tldr -b {inputdir/input_sorted.bam} -e /opt/tldr/ref/teref.ont.human.fa -r {refdir/refseq} -n /opt/tldr/ref/nonref.collection.hg38.chr.bed.gz -p {number of thread} -o {outdir} --color_consensus
#call SNVs using clair3
singularity run {summersifdir}/summer.sif conda run -n clair3 /opt/conda/envs/clair3/bin/run
```

An additional handy SnakeMake is provided for SV calling from bam file:

0, Prepare environments
```bash
conda create -n svim_env --channel bioconda svim
conda install sniffles=2.5.3
conda install -c bioconda cutesv
```
1, Modify the config.yml file
```bash
#Folder where all the outputs are saved
BASE_OUTPUT_DIR: example_outputdir
#Modify: example_outputdir to your output directionary
#Folder where input bam and index file are saved and filename
BASE_INPUT_DIR: example_inputdir/input.bam
#Folder where reference file saved and filename
BASE_REF_DIR: example_refdir/GRch38.fa
#Parameter for analysis
THREADS: number of threads ### SVIM could not run on multi-threading
```
2, Run the process
```bash
snakemake -s work_flow.snakefile --configfile config.yml
```
