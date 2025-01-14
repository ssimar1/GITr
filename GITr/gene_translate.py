#! /usr/bin/env python3

# This script will take a multifasta of nucleotide gene sequences and translate them. It will also translate a reference sequence for comparison/alignment, if desired.

import os
import sys
from Bio import Seq
from Bio import Align
from Bio.Align import _aligners
from Bio import SeqIO
from Bio.Alphabet import IUPAC
from Bio.SeqRecord import SeqRecord

infile = open(sys.argv[1])
gene = sys.argv[3]
outdir = sys.argv[4]

with infile as fw:
    for record in SeqIO.parse(sys.argv[1], "fasta"):
        list_seqs = []
        name=record.id
        seq = str(record.seq)

# Sanity check
        # print(record)
        # print(record)
        # print(record.format("fasta"))
        # print(seq)

# Create a function that translates a sequence and stores it as a SeqRecord object
    def make_aa_record(record):
        return SeqRecord(seq = record.seq.translate(),id=record.id + "_protein", description="")
    allrecords = map(make_aa_record, SeqIO.parse(infile, "fasta"))

# Write out multifasta file
    completeName = os.path.join(outdir,"aminoacid_" + str(gene) + ".fasta")
    SeqIO.write(allrecords, completeName, "fasta")

# Translate reference sequence if you don't have it already
reference = open(sys.argv[2])

with reference as fw:
    for element in SeqIO.parse(sys.argv[2], "fasta"):
        nameref = element.id
        refseq = str(element.seq)

    def make_aa_record_ref(element):
        return SeqRecord(seq = element.seq.translate(), id=element.id + "_" + str(gene) + "_protein_ref", description="")
    refrecord = map(make_aa_record_ref, SeqIO.parse(reference, "fasta"))

 # Add reference sequence to multifasta
    
# Concatenate reference and multifasta files
finalpath = os.path.join(outdir, "combined_" + str(gene) + "_proteinseqs" + ".fasta")
allseqs = [refrecord, completeName]
with open (finalpath, 'w') as outfile:
        for fname in filenames:
                with open(fname) as infile:
                        outfile.write(infile.read())
