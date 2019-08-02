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
REFERENCE=reference_data/reference.fa

# ===== Connect your programs here, assuming installed on your system
BLASTN=/Users/michael.zeller/ncbi_blast/blastn
MAKEBLASTDB=/Users/michael.zeller/ncbi_blast/makeblastdb
SMOF=smof
MAFFT=mafft
FASTTREE=/Users/michael.zeller/FastTree/FastTree
NN_CLASS=treedist.py

# ===== Uncomment and connect your programs here using full path names
# BLASTN=/usr/local/bin/blastn
# MAKEBLASTDB=/usr/local/bin/makeblastdb
# SMOF=/usr/local/bin/smof
# MAFFT=/usr/local/bin/mafft
# FASTTREE=usr/local/bin/FastTree
# NN_CLASS=nn_classifier.R
# ANNOT_FASTA=annotate_headers.pl

# ===== Check if dependencies are available, quit if not

# Attempt to use python3, but if not there check if python is python3
PYTHON=python
if [ -z `which python3` ]; then
    VERCHECK=`python --version | awk -F'.' '{print $1}'`
    [[ ${VERCHECK} == "Python 3" ]] && PYTHON=python || PYTHON=python3
else
    PYTHON=python
fi
echo $PYTHON

# Attempt to use multiprocessor version, but if not there use single processor
# if [ -z `which FastTreeMP` ]; then
#     FASTTREE=FastTree
# else
#     FASTTREE=FastTreeMP
# fi
echo $FASTTREE

# Formal check of dependencies
ERR=0
echo "===== Dependencies check ====="
[ -z `which ${BLASTN}` ]      && echo "blastn      .... need to install" && ERR=1 || echo "blastn      .... good"
[ -z `which ${MAKEBLASTDB}` ] && echo "makeblastdb .... need to install" && ERR=1 || echo "makeblastdb .... good"
[ -z `which ${MAFFT}` ]       && echo "mafft       .... need to install" && ERR=1 || echo "mafft       .... good"
[ -z `which ${FASTTREE}` ]    && echo "FastTree    .... need to install" && ERR=1 || echo "FastTree    .... good"
[ -z `which ${PYTHON}` ]      && echo "python3     .... need to install" && ERR=1 || echo "python3     .... good"
[ -z `which ${SMOF}` ]        && echo "smof        .... need to install" && ERR=1 || echo "smof        .... good"

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
# the H1 gene at pipe 5, the US HA clade at pipe 1, and the Global HA clade at pipe 8.
# These positions may be modified, or extended, to return any metadata required.
echo $PYTHON
[ -s ${OUTDIR}/H1.tre ]  && ${PYTHON} ${NN_CLASS} -i ${OUTDIR}/H1.tre -c 5,1,8 >> ${BASENAME}_Final_Output.txt
[ -s ${OUTDIR}/H3.tre ]  && ${PYTHON} ${NN_CLASS} -i ${OUTDIR}/H3.tre -c 5,1,8 >> ${BASENAME}_Final_Output.txt
[ -s ${OUTDIR}/N1.tre ]  && ${PYTHON} ${NN_CLASS} -i ${OUTDIR}/N1.tre -c 5,1   >> ${BASENAME}_Final_Output.txt
[ -s ${OUTDIR}/N2.tre ]  && ${PYTHON} ${NN_CLASS} -i ${OUTDIR}/N2.tre -c 5,1   >> ${BASENAME}_Final_Output.txt
[ -s ${OUTDIR}/PB2.tre ] && ${PYTHON} ${NN_CLASS} -i ${OUTDIR}/PB2.tre -c 5,1  >> ${BASENAME}_Final_Output.txt
[ -s ${OUTDIR}/PB1.tre ] && ${PYTHON} ${NN_CLASS} -i ${OUTDIR}/PB1.tre -c 5,1  >> ${BASENAME}_Final_Output.txt
[ -s ${OUTDIR}/PA.tre ]  && ${PYTHON} ${NN_CLASS} -i ${OUTDIR}/PA.tre -c 5,1   >> ${BASENAME}_Final_Output.txt
[ -s ${OUTDIR}/NP.tre ]  && ${PYTHON} ${NN_CLASS} -i ${OUTDIR}/NP.tre -c 5,1   >> ${BASENAME}_Final_Output.txt
[ -s ${OUTDIR}/M.tre ]   && ${PYTHON} ${NN_CLASS} -i ${OUTDIR}/M.tre -c 5,1    >> ${BASENAME}_Final_Output.txt
[ -s ${OUTDIR}/NS.tre ]  && ${PYTHON} ${NN_CLASS} -i ${OUTDIR}/NS.tre -c 5,1   >> ${BASENAME}_Final_Output.txt
cp ${BASENAME}_Final_Output.txt ${OUTDIR}/.

echo "==== Final results in  ${BASENAME}_Final_Output.txt"
echo "alignment and tree files in the '${OUTDIR}' folder"
echo "Tree files are listed below: "
ls -ltr ${OUTDIR}/*.tre
