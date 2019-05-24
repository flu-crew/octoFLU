# Automated classification of influenza A virus gene sequences detected in U.S. swine to evolutionary origin

[![Docker Automated build](https://img.shields.io/docker/automated/j23414/nn_patristic_classifier.svg)](https://hub.docker.com/r/j23414/nn_patristic_classifier/)

## Use
Determines evolutionary origin of influenza A virus genes through inference of maximum likelihood tree and then assignment of a defined genetic clade  based on nearest neighbor determined by patristic distances.

This tool has been tested on swine H1 and H3 data, sequence from other serotypes or sequence that is too short  may generate incorrect results. We suggest you use the [IRD Sequence Annotation tool](https://www.fludb.org/brc/influenza_batch_submission.spg?method=NewAnnotation&decorator=influenza) prior to running this pipeline. 

We also recommend that output from the automatic classification be interpreted conservatively, and that more comprehensive phylogenetic analyses may be required for accurate determination of evolutionary history.

If you use this pipeline or the curated reference datasets in your work, please cite:

Chang, J.*, Anderson, T.K.*, Zeller, M.A.*, Gauger, P.C., Vincent, A.L. Automated classification of influenza A virus gene sequences detected in U.S. swine to evolutionary origin. bioRxiv: XXXX. *These authors contributed equally.

## Input
Unaligned fasta with query sequences (e.g., strain name with protein segment identifier).

## Output
* Text output stating the query name, protein symbol, and genetic clade. 
* Text output holding the query name and top BLASTn hit. 
* Inferred maximum likelihood trees with reference gene sets and queries.

## Usage

```
bash pipeline.sh sample_data/query.fasta
```
## Running the pipeline

Edit the paths in `pipeline.sh`. You will need to have an installation of 

* [NCBI Blast](https://blast.ncbi.nlm.nih.gov/Blast.cgi?CMD=Web&PAGE_TYPE=BlastDocs&DOC_TYPE=Download), 
* [smof](https://github.com/incertae-sedis/smof),
* [mafft](https://mafft.cbrc.jp/alignment/software/), 
* [FastTree](http://www.microbesonline.org/fasttree/#Install)
* [R](https://www.r-project.org)
* [Perl](https://www.perl.org)
* and the included `nn_classifier.R` script
* and the included `annotate_headers.pl` script

```
# Connect your reference dataset here
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

The output will be in a `*_Final_Output.txt` file and `*_output` folder, any trees generated will be listed and named by protein symbol, and `blast_output.txt` includes the query genes and their top BLASTn hit.

The main bottleneck is waiting for trees to run in FastTree (an installation of multi-threaded version helps). A sampling of the output is included, split by `...`.

```
bash pipeline.sh sample_data/query.fasta

less query.fasta_Final_Output.txt

QUERY_MH540411_A/swine/Iowa/A02169143/2018		    H1	pdm		1A.3.3.2 
QUERY_MH595470_A/swine/South_Dakota/A02170160/2018	H1	delta1	1B.2.2.2 
QUERY_MH595472_A/swine/Illinois/A02170163/2018		H1	alpha	1A.1.1 
...
QUERY_MH546131_A/swine/Minnesota/A01785562/2018		H3	2010-human_like	3.2010.1 
QUERY_MH561745_A/swine/Minnesota/A01785568/2018		H3	2010-human_like	3.2010.1 
QUERY_MH551260_A/swine/Iowa/A02016898/2018			H3	2010-human_like	3.2010.1 
...
QUERY_MH551259_A/swine/Iowa/A02016897/2018			N1	classicalSwine 
QUERY_MH561752_A/swine/Minnesota/A01785574/2018		N1	classicalSwine 
QUERY_MH551263_A/swine/Minnesota/A02016891/2018		N1	classicalSwine 
...
QUERY_MK024152_A/swine/Minnesota/A01785613/2018		N2	1998 
QUERY_MH976804_A/swine/Michigan/A01678583/2018		N2	1998
QUERY_MH595471_A/swine/South_Dakota/A02170160/2018	N2	2002 
...
QUERY_MH922882_A/swine/Ohio/18TOSU4536/2018		M	pdm 
QUERY_MK321295_A/swine/Florida/A01104129/2018	M	pdm
QUERY_MK129490_A/swine/Illinois/A02170163/2018	M	pdm
...
QUERY_MK185286_A/swine/Iowa/A02016889/2018	PB1	TRIG 
QUERY_MK185322_A/swine/Iowa/A02169143/2018	PB1	pdm
QUERY_MK039744_A/swine/Iowa/A02254795/2018	PB1	TRIG
```

## Docker

Start the Docker deamon and navigate to your query file location. 

```
cd mydataset/
docker pull j23414/nn_patristic_classifier
docker run -it -v ${PWD}:/data nn_patristic_classifier:latest /bin/bash
```

From inside the docker image you should be able to run the pipeline. Remember to copy files to `/data` to pull them out of the docker image to your computer.

```
docker > bash pipeline.sh sample_data/sample2.fasta
docker > cp -rf sample2.fasta_output /data/.
docker > exit 
```

## Singularity

Singularity and Docker are friends. A singularity image can be built using singularity pull. 


```
singularity pull docker://j23414/nn_patristic_classifier
```

## Future Considerations
* Reannotate the tree with NN-clades for ease of use.
* Integrate the mergeGC.R script to combine gene assignments to a whole genome constellation descriptor.
