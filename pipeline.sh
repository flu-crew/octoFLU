#! /usr/bin/env bash
# Auth: Jennifer Chang
# Date: 2019/03/13

set -e
set -u

# ===== Input and Output
INPUT=$1
BASENAME=$(basename $1)
OUTDIR="${BASENAME}_output"
# ===== Create Output Directory if not already created
[ -d ${OUTDIR} ] || mkdir ${OUTDIR} 

# ===== Connect your reference here
REFERENCE=sample_data/reference.fa

# ===== Connect your programs here, assuming installed on your system
BLASTN=blastn
MAKEBLASTDB=makeblastdb
SMOF=smof.py
MAFFT=mafft
FASTTREE=FastTreeMP
NN_CLASS=nn_classifier.R
ANNOT_FASTA=annotate_headers.pl

# ===== Uncomment and connect your programs here using full path names

# BLASTN=/usr/local/bin/blastn
# MAKEBLASTDB=/usr/local/bin/makeblastdb
# SMOF=/usr/local/bin/smof
# MAFFT=/usr/local/bin/mafft
# FASTTREE=usr/local/bin/FastTree
# NN_CLASS=nn_classifier.R
# ANNOT_FASTA=annotate_headers.pl

# ===== Check if dependencies are avialable, quit if not

ERR=0

echo "===== Dependencies check ====="
[ -z `which ${BLASTN}` ]      && echo "blastn      .... need to install" && ERR=1 || echo "blastn      .... good"
[ -z `which ${MAKEBLASTDB}` ] && echo "makeblastdb .... need to install" && ERR=1 || echo "makeblastdb .... good"
[ -z `which ${SMOF}` ]        && echo "smof.py     .... need to install" && ERR=1 || echo "smof        .... good"
[ -z `which ${MAFFT}` ]       && echo "mafft       .... need to install" && ERR=1 || echo "mafft       .... good"
[ -z `which ${FASTTREE}` ]    && echo "FastTree    .... need to install" && ERR=1 || echo "FastTree    .... good"
[ -z `which Rscript` ]        && echo "R           .... need to install" && ERR=1 || echo "R           .... good"
[ -z `which perl` ]           && echo "Perl        .... need to install" && ERR=1 || echo "Perl        .... good"

if [[ $ERR -eq 1 ]]
then
    echo "Link or install any of your 'need to install' programs above"
    exit
fi

# ===== Remove pipes in query header
cat ${INPUT} | tr '|' '_' > ${BASENAME}.clean

# ===== Create your Blast Database
# ${MAKEBLASTDB} -in ${REFERENCE} -parse_seqids -dbtype nucl      # requires no spaces in header
${MAKEBLASTDB} -in ${REFERENCE} -dbtype nucl                      # allows spaces in header

# ===== Search your Blast Database
${BLASTN} -db ${REFERENCE} -query ${BASENAME}.clean -num_alignments 1 -outfmt 6 -out ${OUTDIR}/blast_output.txt

echo "... results in ${OUTDIR}/blast_output.txt"

# ===== Split out query into 8 segments
cat ${OUTDIR}/blast_output.txt |awk -F'\t' '$2~/\|H1\|/  {print $1}' > ${OUTDIR}/H1.ids
cat ${OUTDIR}/blast_output.txt |awk -F'\t' '$2~/\|H3\|/  {print $1}' > ${OUTDIR}/H3.ids
cat ${OUTDIR}/blast_output.txt |awk -F'\t' '$2~/\|N1\|/  {print $1}' > ${OUTDIR}/N1.ids
cat ${OUTDIR}/blast_output.txt |awk -F'\t' '$2~/\|N2\|/  {print $1}' > ${OUTDIR}/N2.ids
cat ${OUTDIR}/blast_output.txt |awk -F'\t' '$2~/\|PB2\|/ {print $1}' > ${OUTDIR}/PB2.ids
cat ${OUTDIR}/blast_output.txt |awk -F'\t' '$2~/\|PB1\|/ {print $1}' > ${OUTDIR}/PB1.ids
cat ${OUTDIR}/blast_output.txt |awk -F'\t' '$2~/\|PA\|/  {print $1}' > ${OUTDIR}/PA.ids
cat ${OUTDIR}/blast_output.txt |awk -F'\t' '$2~/\|NP\|/  {print $1}' > ${OUTDIR}/NP.ids
cat ${OUTDIR}/blast_output.txt |awk -F'\t' '$2~/\|M\|/   {print $1}' > ${OUTDIR}/M.ids
cat ${OUTDIR}/blast_output.txt |awk -F'\t' '$2~/\|NS\|/  {print $1}' > ${OUTDIR}/NS.ids

ARR=(H1 H3 N1 N2 PB2 PB1 PA NP M NS)

# Fast part, separating out the sequences and adding references
for SEG in "${ARR[@]}"
do
    echo "${SEG}"
    if [ -s ${OUTDIR}/${SEG}.ids ]
    then 
	${SMOF} grep -Xf ${OUTDIR}/${SEG}.ids ${BASENAME}.clean > ${OUTDIR}/${SEG}.fa   # pull out query by segment
	${SMOF} grep "|$SEG|" ${REFERENCE} >> ${OUTDIR}/${SEG}.fa              # add references
    fi
    rm ${OUTDIR}/${SEG}.ids
done

# Slow part, building the alignment and tree
for SEG in "${ARR[@]}"
do
    echo "${SEG}"
    if [ -s ${OUTDIR}/${SEG}.fa ]
    then 
	${MAFFT} --thread -1 --auto --reorder ${OUTDIR}/${SEG}.fa > ${OUTDIR}/${SEG}_aln.fa
	${FASTTREE} -nt -gtr -gamma ${OUTDIR}/${SEG}_aln.fa > ${OUTDIR}/${SEG}.tre # can drop -gtr -gamma for faster results
	rm ${OUTDIR}/${SEG}.fa
    fi
done

# Fast again, pull out clades
[[ -f ${BASENAME}_Final_Output.txt ]] && rm ${BASENAME}_Final_Output.txt
touch ${BASENAME}_Final_Output.txt
# Annotations are based upon reading reference set deflines. For example, H1 genes have
# the H1 gene at pipe 4, the US HA clade at pipe 7, and the Global HA clade at pipe 8.
# These positions may be modified, or extended, to return any metadata required.
[ -s ${OUTDIR}/H1.tre ]  && Rscript ${NN_CLASS} ${OUTDIR}/H1.tre 4 7 8 >> ${BASENAME}_Final_Output.txt
[ -s ${OUTDIR}/H3.tre ]  && Rscript ${NN_CLASS} ${OUTDIR}/H3.tre 4 7 8 >> ${BASENAME}_Final_Output.txt
[ -s ${OUTDIR}/N1.tre ]  && Rscript ${NN_CLASS} ${OUTDIR}/N1.tre 5 1   >> ${BASENAME}_Final_Output.txt
[ -s ${OUTDIR}/N2.tre ]  && Rscript ${NN_CLASS} ${OUTDIR}/N2.tre 5 1   >> ${BASENAME}_Final_Output.txt
[ -s ${OUTDIR}/PB2.tre ] && Rscript ${NN_CLASS} ${OUTDIR}/PB2.tre 5 1  >> ${BASENAME}_Final_Output.txt
[ -s ${OUTDIR}/PB1.tre ] && Rscript ${NN_CLASS} ${OUTDIR}/PB1.tre 5 1  >> ${BASENAME}_Final_Output.txt
[ -s ${OUTDIR}/PA.tre ]  && Rscript ${NN_CLASS} ${OUTDIR}/PA.tre 5 1   >> ${BASENAME}_Final_Output.txt
[ -s ${OUTDIR}/NP.tre ]  && Rscript ${NN_CLASS} ${OUTDIR}/NP.tre 5 1   >> ${BASENAME}_Final_Output.txt
[ -s ${OUTDIR}/M.tre ]   && Rscript ${NN_CLASS} ${OUTDIR}/M.tre 5 1    >> ${BASENAME}_Final_Output.txt
[ -s ${OUTDIR}/NS.tre ]  && Rscript ${NN_CLASS} ${OUTDIR}/NS.tre 5 1   >> ${BASENAME}_Final_Output.txt
cp ${BASENAME}_Final_Output.txt ${OUTDIR}/.

perl ${ANNOT_FASTA} ${BASENAME}_Final_Output.txt ${INPUT} > ${BASENAME}_annot.fasta
cp ${BASENAME}_annot.fasta ${OUTDIR}/.

echo "==== Final results in  ${BASENAME}_Final_Output.txt"
echo "==== Annotated fasta in  ${BASENAME}_annot.fasta"
echo "alignment and tree files in the '${OUTDIR}' folder"
echo "Tree files are listed below: "
ls -ltr ${OUTDIR}/*.tre
