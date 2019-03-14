# Classification of influenza A virus gene sequences detected in U.S. swine to evolutionary origin
## Use
Determines evolutionary origin of influenza A virus genes through inference of maximum likelihood tree and then assignment of a gdefined genetic clade  based on nearest neighbor determined by patristic distances.

## Input
Unaligned fasta with query sequences (deflione without "|").

## Output
Text output stating the query name, protein symbol, and genetic clade. An additional output file holds the query name and top BLASTn hit.

## Usage

```
Rscript nn_classifier.R path-to-tree-file
```

## Future Considerations
Reannotate the tree with NN-clades for ease of use.

## Running the pipeline

Edit the paths in `pipeline.sh`. You will need to have an installation of NCBI Blast, [smof](https://github.com/incertae-sedis/smof), mafft, FastTree and the included `nn_classifier.R` script.

```
# Connect your reference here
REFERENCE=sample_data/reference.fa

# Connect your programs here, can use full path names
BLASTN=~/bin/blastn
MAKEBLASTDB=~/bin/makeblastdb
SMOF=~/bin/smof
MAFFT=`which mafft`
FASTTREE=~/bin/FastTree
NN_CLASS=nn_classifier.R
```

Then run the pipeline

```
bash pipeline.sh sample_data/query.fasta
```

The output will be in a `*_Final_Output.txt` file, and any trees will be listed.

```
bash pipeline.sh sample_data/query.fasta
less query.fasta_Final_output.txt

A02430617	H1	alpha 
A02430842|alpha	H1	alpha 
A02430609|alpha	H1	alpha 
A02430671|gamma	H1	gamma 
A02430672|gamma	H1	gamma 
A02430761|gamma	H1	gamma 
```

A longer example. This main bottleneck is waiting for trees to run in FastTree. A sampling of the output is included, split by `...`.

```
bash pipeline.sh sample_data/query.fasta

less query.fasta_Final_Output.txt

QUERY_JN652498_A/swine/Indiana/A01049794/2011_H1N2_2011/04/06_H1_delta1b_02A_2_TTTPPT   H1      delta1b 
QUERY_MF000477_A/swine/North_Carolina/A02214000/2017_H1N2_2017/03/16_H1_alpha_02B_1_TTPPPT      H1      alpha 
QUERY_KF150184_A/swine/Nebraska/A01380503/2013_H1N1_2013/05/07_H1_beta_Classical_TTTTTT H1      beta 
QUERY_MH350902_A/swine/Nebraska/A02157974/2018_H1N1_2018/04/18_H1_gamma2-beta-like_MN99_TVVVVT  H1      gamma2-beta-like
...
QUERY_CY114857_A/swine/Minnesota/A01201895/2011_H3N2_2011/07/05_H3_Cluster_IVD_2002B_TPPPPP     H3      Cluster_IVD 
QUERY_JX657749_A/swine/Illinois/A01240775/2012_H3N2_2012/01/09_H3_Cluster_IVE_02A_2_TTPPPT      H3      Cluster_IVE 
QUERY_JQ783074_A/swine/Illinois/A01201076/2011_H3N2_2011/04/07_H3_Cluster_IVF_98A_2_TTTPPP      H3      Cluster_IVF 
...
QUERY_KX928653_A/swine/Indiana/A01781271/2016_H1N1_2016/09/14_N1_gamma_Classical_TTPPPT N1      Classical 
QUERY_KF150185_A/swine/Nebraska/A01380503/2013_H1N1_2013/05/07_N1_beta_Classical_TTTTTT N1      Classical 
QUERY_MF692782_A/swine/North_Carolina/A01785281/2017_H1N1_2017/07/28_N1_gamma_Classical_TTTPPT  N1      Classical
...
QUERY_JX092572_A/swine/Indiana/A01202866/2011_H3N2_2011/11/16_N2_Cluster_IVC_2002B_PTPPPT       N2      2002B 
QUERY_CY114858_A/swine/Minnesota/A01201895/2011_H3N2_2011/07/05_N2_Cluster_IVD_2002B_TPPPPP     N2      2002B 
QUERY_MF471677_A/swine/Oklahoma/A02218159/2017_H3N2_2017/06/12_N2_human-like_2010.2_2016_TTTTPT N2      2016 
...
QUERY_JX306665_A/swine/Illinois/A01240775/2012_H3N2_2012/01/09_PB2_Cluster_IVE_02A_2_TTPPPT     PB2     TTPPPT 
QUERY_JX182047_A/swine/Minnesota/A01201895/2011_H3N2_2011/07/05_PB2_Cluster_IVD_2002B_TPPPPP    PB2     TPPPPP 
QUERY_JQ791001_A/swine/Illinois/A01047014/2010_H3N2_2010/11/22_PB2_Cluster_IV_Human_N2_TTTTTT   PB2     TTTPTT
...

```
