# GITr
These scripts utilize output from a custom ABRicate gene database to index a FASTA assembly file and pull out the gene of interest from it. Then, using the .py script, the gene is translated into the amino acid space, and an alignment is generated. These scripts are meant to be used on multiple files at once.

Gene indexing and translation script SOP

Setting up custom databases to run ABRicate
•	Load ABRicate and create your custom ABRicate “database” in the following format (.fasta file). You can put this file wherever it is convenient for you.
The multifasta should look like this, with the following as the header:
>newdb~~~GENE_ID~~~GENE_ACC~~RESISTANCES/some description here

 	>module load abricate
•	Follow ABRicate instructions to create your own database:
% cd /path/to/abricate/db     # this is the --datadir default option
#On our server: /data/opt/programs/etc/abricate/abricate/V1.0.1/db is our file path—must do this from server 1
% mkdir <newdb>
% cd <newdb>

% cp /path/to/<newdb>.fa sequences


% head -n 1 sequences
>newdb~~~GENE_ID~~~GENE_ACC~~~RESISTANCES some description here

% abricate –setupdb (run in new db folder)

% # or do this: makeblastdb -in sequences -title tinyamr -dbtype nucl -hash_index

% abricate --list
DATABASE  SEQUENCES  DBTYPE  DATE
newdb   173        nucl    2019-Aug-28


% abricate --db newdb screen_this.fasta
(Source: https://github.com/tseemann/abricate)

•	Run ABRicate, example command:
% for F in *.fasta; do abricate --db <newdb> --mincov 80 --minid 80 $F > ${F%.fasta}_abricate.tab; done
a.	This is where you can check for gene presence/absence most easily

From here, you can use abricate’s –-summary option
abricate –summary *.tab > ChaseStaph_CHGgenes.tab
 to get your binary presence/absence matrix



Running the scripts
•	Load samtools and python3
 module load samtools/samtools-1.10 – you need this specific version
 module load python/python-3.7.0
•	Pieces to make sure you have (also written in the script itself)
a.	ABRICATE = .tab file you just created with your gene(s) of interest
b.	REF = genome assembly (.fasta file) of your sample(s) of interest
c.	OUTPUTLOCATION = wherever you want to save the output—DO NOT create beforehand or the script will break
d.	GENEREF = a nucleotide reference .fasta file for your gene of interest—call it [genename]_ref.fasta – make sure capitalization/spelling match exactly what was used in the ABRicate file for GENEID
•	Run!
>bash /data/opt/scripts/Shelby_gene_index_translate_scripts/gene_indexing.sh <abricate file> <assembly fasta> <output directory> <reference gene fasta>

*Note: can use full or relative paths, can also  do this as a for loop
*fastas, when used for abricate, must be in the directory in which you run the command
*samtools will not work on zipped fasta files, so unzip first
