#! /usr/bin/env bash
# Auth: Jennifer Chang
# Date: 2019/03/13

set -e
set -u

# Input and Output
INPUT=$1
BASENAME=$(basename $1)

# Connect your programs here, can use full path names
BLASTN=~/bin/blastn
SMOF=~/bin/smof
MAFFT=`which mafft`
FASTTREE=~/bin/FastTree
MICHAEL=nn_classifier.R

# Create your Blast Database

# Search your Blast Database
${BLASTN} -db reference.fa -query $INPUT -num_alignments 1 -outfmt 6 -out ${BASENAME}_output.txt

echo "... results in ${BASENAME}_output.txt"

cat ${BASENAME}_output.txt |awk -F'\t' '$2~/\|H1\|/ {print $1}' > ${BASENAME}_H1.ids
cat ${BASENAME}_output.txt |awk -F'\t' '$2~/\|H3\|/ {print $1}' > ${BASENAME}_H3.ids
cat ${BASENAME}_output.txt |awk -F'\t' '$2~/\|N1\|/ {print $1}' > ${BASENAME}_N1.ids
cat ${BASENAME}_output.txt |awk -F'\t' '$2~/\|N2\|/ {print $1}' > ${BASENAME}_N2.ids
cat ${BASENAME}_output.txt |awk -F'\t' '$2~/\|PB2\|/ {print $1}' > ${BASENAME}_PB2.ids
cat ${BASENAME}_output.txt |awk -F'\t' '$2~/\|PB1\|/ {print $1}' > ${BASENAME}_PB1.ids
cat ${BASENAME}_output.txt |awk -F'\t' '$2~/\|PA\|/ {print $1}' > ${BASENAME}_PA.ids
cat ${BASENAME}_output.txt |awk -F'\t' '$2~/\|NP\|/ {print $1}' > ${BASENAME}_NP.ids
cat ${BASENAME}_output.txt |awk -F'\t' '$2~/\|M\|/ {print $1}' > ${BASENAME}_M.ids
cat ${BASENAME}_output.txt |awk -F'\t' '$2~/\|NS\|/ {print $1}' > ${BASENAME}_NS.ids

ARR=(H1 H3 N1 N2 PB2 PB1 PA NP M NS)

# Fast part, separating out the sequences and adding references
for SEG in "${ARR[@]}"
do
    echo "${SEG}"
    if [ -s ${BASENAME}_${SEG}.ids ]
    then 
	${SMOF} grep -Xf ${BASENAME}_${SEG}.ids ${INPUT} > ${BASENAME}_${SEG}.fa   # pull out by segment
	${SMOF} grep "|$SEG|" reference.fa >> ${BASENAME}_${SEG}.fa                # add references
    fi
done

# Slow part, building the alignment and tree
for SEG in "${ARR[@]}"
do
    echo "${SEG}"
    if [ -s ${BASENAME}_${SEG}.ids ]
    then 
	${MAFFT} --auto ${BASENAME}_${SEG}.fa > ${BASENAME}_${SEG}_aln.fa
	${FASTTREE} -nt ${BASENAME}_${SEG}_aln.fa > ${BASENAME}_${SEG}.tre
    fi
done

# Fast again, pull out clades
touch ${BASENAME}_Final_Output.txt
rm ${BASENAME}_Final_Output.txt
touch ${BASENAME}_Final_Output.txt

[ -s ${BASENAME}_H1.ids ] && Rscript ${MICHAEL} ${BASENAME}_H1.tre 5 6 >> ${BASENAME}_Final_Output.txt
[ -s ${BASENAME}_H3.ids ] && Rscript ${MICHAEL} ${BASENAME}_H3.tre 5 6 >> ${BASENAME}_Final_Output.txt
[ -s ${BASENAME}_N1.ids ] && Rscript ${MICHAEL} ${BASENAME}_N1.tre 5 7 >> ${BASENAME}_Final_Output.txt
[ -s ${BASENAME}_N2.ids ] && Rscript ${MICHAEL} ${BASENAME}_N2.tre 5 7 >> ${BASENAME}_Final_Output.txt
[ -s ${BASENAME}_PB2.ids ] && Rscript ${MICHAEL} ${BASENAME}_PB2.tre 5 8 >> ${BASENAME}_Final_Output.txt
[ -s ${BASENAME}_PB1.ids ] && Rscript ${MICHAEL} ${BASENAME}_PB1.tre 5 8 >> ${BASENAME}_Final_Output.txt
[ -s ${BASENAME}_PA.ids ] && Rscript ${MICHAEL} ${BASENAME}_PA.tre 5 8 >> ${BASENAME}_Final_Output.txt
[ -s ${BASENAME}_NP.ids ] && Rscript ${MICHAEL} ${BASENAME}_NP.tre 5 8 >> ${BASENAME}_Final_Output.txt
[ -s ${BASENAME}_M.ids ] && Rscript ${MICHAEL} ${BASENAME}_M.tre 5 8 >> ${BASENAME}_Final_Output.txt
[ -s ${BASENAME}_NS.ids ] && Rscript ${MICHAEL} ${BASENAME}_NS.tre 5 8 >> ${BASENAME}_Final_Output.txt
