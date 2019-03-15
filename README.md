# Classification of influenza A virus gene sequences detected in U.S. swine to evolutionary origin

[![Docker Automated build](https://img.shields.io/docker/automated/j23414/nn_patristic_classifier.svg)](https://hub.docker.com/r/j23414/nn_patristic_classifier/)

## Use
Determines evolutionary origin of influenza A virus genes through inference of maximum likelihood tree and then assignment of a defined genetic clade  based on nearest neighbor determined by patristic distances.

## Input
Unaligned fasta with query sequences (defline without "|").

## Output
Text output stating the query name, protein symbol, and genetic clade. An additional output file holds the query name and top BLASTn hit.

## Usage

```
bash pipeline.sh sample_data/query.fasta
```

## Future Considerations
Reannotate the tree with NN-clades for ease of use.

## Running the pipeline

Edit the paths in `pipeline.sh`. You will need to have an installation of 

* [NCBI Blast](https://blast.ncbi.nlm.nih.gov/Blast.cgi?CMD=Web&PAGE_TYPE=BlastDocs&DOC_TYPE=Download), 
* [smof](https://github.com/incertae-sedis/smof),
* [mafft](https://mafft.cbrc.jp/alignment/software/), 
* [FastTree](http://www.microbesonline.org/fasttree/#Install)
* and the included `nn_classifier.R` script.

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
QUERY_MK024152_A/swine/Minnesota/A01785613/2018		N2	1998_NA_N2 
QUERY_MH976804_A/swine/Michigan/A01678583/2018		N2	1998_NA_N2 
QUERY_MH595471_A/swine/South_Dakota/A02170160/2018	N2	2002_NA_N2 
...
QUERY_MH922882_A/swine/Ohio/18TOSU4536/2018		M	pdm_EurasianSwOrigin 
QUERY_MK321295_A/swine/Florida/A01104129/2018	M	pdm_EurasianSwOrigin 
QUERY_MK129490_A/swine/Illinois/A02170163/2018	M	pdm_EurasianSwOrigin
...
QUERY_MK185286_A/swine/Iowa/A02016889/2018	PB1	TRIG_huOrigin 
QUERY_MK185322_A/swine/Iowa/A02169143/2018	PB1	pdm_TRIGhuOrigin 
QUERY_MK039744_A/swine/Iowa/A02254795/2018	PB1	TRIG_huOrigin
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
