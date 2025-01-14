#!/bin/bash

# This pipeline (well, series of scripts) will take assemblies and gene location input from Abricate, pull out the gene of interest, and translate the nucleotide sequences into the amino acid space for identification of mutations or other interesting things.

# Input required:
## ABRICATE = .tab file created by ABRicate. Create a custom database in ABRicate with your genes of interest to get the info needed in the ABRicate output file.
##  REF = genome assembly (.fasta file) of your sample(s) of interest
##  OUTPUTLOCATION = wherever you want to save the output
##  GENEREF = nucleotide reference for gene of interest


## NOTE: Requires samtools, python3

USAGE= echo "
Usage: bash $0 ABRICATE REF OUTPUTLOCATION GENEREF"

# If running this on Arias server
module load samtools/samtools-1.10
module load python/python-3.7.0

# Define variables
ABRICATE=$1
REF=$2
OUTPUTLOCATION=$3
GENEREF=$4

# Make directory for output files if there isn't one already
mkdir -p $OUTPUTLOCATION

# Not the most elegant way to do this, but will pull out the gene name to be used in downstream processes so you don't have to create a new script for each gene
GENEFILE=${GENEREF##*/}
GENENAME=${GENEFILE%_ref.*}

# Sanity check to make sure this worked
# echo $GENEFILE $GENENAME

# Pull out line containing gene of interest from ABRicate .tab file

awk -v gene="$GENENAME" '$6~gene' $ABRICATE > ${GENENAME}.txt

# Set variables
SAMPNAME=$(cut -f 1 ${GENENAME}.txt)
CONTIG=$(cut -f 2 ${GENENAME}.txt)
START=$(cut -f 3 ${GENENAME}.txt)
STOP=$(cut -f 4 ${GENENAME}.txt)
STRAND=$(cut -f 5 ${GENENAME}.txt)
strandtype="${STRAND}"
REGIONFILE=${SAMPNAME%.*}_regionfile.txt
echo "${CONTIG}:${START}-${STOP}" > $REGIONFILE
OUTPUTFILE=${SAMPNAME%.*}_${GENENAME}.fa

# Sanity check
echo "Sample, contig, and strandedness check"
echo $SAMPNAME
echo $CONTIG
echo $STRAND

# Modify gene.txt file to parse with samtools faidx
nl=$(wc -l < ${GENENAME}.txt)
nl=$(($nl))

# Check number of lines in .txt file, then run (conditionally)
# NOTE: this script cannot handle multiple copies of genes (yet)
if [[ $nl == 1 && $strandtype == "+" ]]; then
        samtools faidx $REF -o $OUTPUTFILE -r $REGIONFILE
elif [[ $strandtype == "-" ]]; then
        samtools faidx $REF -o $OUTPUTFILE -r $REGIONFILE -i --mark-strand sign
else
        echo "ERROR-- too many lines in file"
fi

# Append SAMPNAME to file header
for i in $OUTPUTFILE; do sed "1s/.*/>${i%.fa}/" $i > $OUTPUTLOCATION/$OUTPUTFILE; rm $i; done

# Create multi-fasta file with gene of interest from each assembly
MULTIFASTA=${GENENAME}_multifasta_dna.fasta
cat $OUTPUTLOCATION/C*_${GENENAME}.fa > $MULTIFASTA

# Run Python script to translate sequences using defined variables from the bash script
python3 /home/ssimar/scripts/test/gene_translate.py $MULTIFASTA $GENEREF $GENENAME $OUTPUTLOCATION
