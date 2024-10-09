# **SUMMER**
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

## **Complete User Guide**
For full instructions on how to install and use **SUMMER**, please refer to the [official documentation](https://pku-edu.gitbook.io/summer-pipeline-for-long-read-sequencing/).

## **Pipeline Workflow**
![Pipeline Interface](https://github.com/carolhuaxia/summer/assets/54387977/81f5db90-176c-4d6a-a81d-7690a9f292f5)

The pipeline consists of several key stages, each designed to handle specific tasks in long-read sequencing:

1. **Preprocessing**: Quality control and read filtering with **PanDepth**.
2. **Alignment**: Mapping long-read sequences to the reference genome.
3. **Variation Detection**: Identifying structural variations, mobile elements, and mutations.
4. **Annotation**: Annotating the detected variations to provide clinical insights.

## **Quick Start**
Detail usage can be seen in the **official documentation** above

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
You may also able to enter a container in an interactive way :
```bash
docker run -it chuhongyuan/summer:latest
```
