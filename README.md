# Lineage and Mutation Monitor

A quick monitoring script that uses some of my bag'o'covid-19 scripts to
monitor daily changes in the nextstrain ingested data from GISAID.

This takes the nextmeta and nextfasta files from GISAID 
(either downloaded manually, or using the GISAID API and [ncov-ingest](https://github.com/nextstrain/ncov-ingest)):

    1. Extracts all Canadian genomes
    2. Quickly annotates mutations using [nextclade](https://github.com/nextstrain/nextclade)
    3. Adds the mutation information to the nextmeta file
    4. Compares to the previous day's nextmeta file with mutation information
    5. Generates an HTML report showing changes and any new mutations/lineages in Canada

To automate this add this to a cronjob or systemd timer

## Installation

Dependencies:
    - biopython (extracting Canadian genomes)
    - pandas (parsing and manipulating data tables)
    - plotly (generating the interactive report)
    - nextclade (annotates mutations)

These can be installed in an env as follows:

    conda env create -f lineage_mutation_monitor.env
    conda activate lineage_mutation_monitor
    npm install -g @neherlab/nextclade

## Usage

The first time you use this you have to generate the initial 
metadata file annotated with mutations for comparison.

This can be done by placing the nextmeta and nextfasta file from GISAID into
a directory named with the date and running e.g.,

    ├── 2021_01_13
        ├── metadata_2021-01-12_17-38.tsv.gz
        └── sequences_2021-01-12_17-48.fasta.gz

and running:

    bash first_time.sh 2021_01_14

This will generate the required files (`canada_seqs_2021_01_13_mutations_and_metadata.tsv`):

    ├── 2021_01_13
        ├── canada_seqs_2021_01_13_metadata.tsv
        ├── canada_seqs_2021_01_13_mutations_and_metadata.tsv
        ├── canada_seqs_2021_01_13_seqs.fasta
        ├── metadata_2021-01-12_17-38.tsv.gz
        ├── nextclade_canada_seqs_2021_01_13.tsv
        └── sequences_2021-01-12_17-48.fasta.gz

Then each day you just need to download that day's nextmeta and nextfasta
file into a directory named with the date in `YYYY_MM_DD` format:

    ├── 2021_01_14
        ├── metadata_2021-01-13_09-12.tsv.gz
        └── sequences_2021-01-13_08-22.fasta.gz

and run:

    bash monitor.sh

This will generate the metadata file with mutations for the new day (`2021_01_14`)
and create a report `2021_01_14/report.html` comparing the mutations and lineages
between the two days:

    ├── 2021_01_13
    │   ├── canada_seqs_2021_01_13_metadata.tsv
    │   ├── canada_seqs_2021_01_13_mutations_and_metadata.tsv
    │   ├── canada_seqs_2021_01_13_seqs.fasta
    │   ├── metadata_2021-01-12_17-38.tsv.gz
    │   ├── nextclade_canada_seqs_2021_01_13.tsv
    │   └── sequences_2021-01-12_17-48.fasta.gz
    ├── 2021_01_14
        ├── canada_seqs_2021_01_14_metadata.tsv
        ├── canada_seqs_2021_01_14_mutations_and_metadata.tsv
        ├── canada_seqs_2021_01_14_seqs.fasta
        ├── metadata_2021-01-13_09-12.tsv.gz
        ├── nextclade_canada_seqs_2021_01_14.tsv
        ├── report.html
        └── sequences_2021-01-13_08-22.fasta.gz

