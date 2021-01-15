#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

yesterday=$(date -d "yesterday" '+%Y_%m_%d')
today=$(date '+%Y_%m_%d')

# acquire today's nextstrain dump from GISAID
# add the "API" download script here, manually download, or use ncov-ingest
#**********************************************

# extract canadian genomes
python covid-19-scripts/extract_seqs.py -m "$today"/metadata*.tsv.gz \
        -f "$today"/sequences*.fasta.gz -q "country=='Canada'" \
        -o "$today"/canada_seqs_"$today"

# run nextclade, extract mutations, and add to
nextclade --input-fasta "$today"/canada_seqs_"$today"_seqs.fasta \
          --output-tsv "$today"/nextclade_canada_seqs_"$today".tsv

python covid-19-scripts/collect_mutations.py \
        --nextclade "$today"/nextclade_canada_seqs_"$today".tsv \
        --metadata "$today"/canada_seqs_"$today"_metadata.tsv \
        --output "$today"/canada_seqs_"$today"_mutations_and_metadata.tsv \
        --gene all,S,E

# compare pangolin lineages (report any new ones compared to previous day)
python covid-19-scripts/compare_lineages_and_mutations.py \
            --previous "$yesterday"/canada_seqs_"$yesterday"_mutations_and_metadata.tsv \
            --current "$today"/canada_seqs_"$today"_mutations_and_metadata.tsv \
            --output "$today"/report.html
