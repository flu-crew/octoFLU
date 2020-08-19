<p align="center">
  <img src="https://github.com/flu-crew/octoFLU/blob/master/img/octoFLU_revised_V3-01.png">
</p>

# octoFLU: Automated classification to evolutionary origin of influenza A virus gene sequences detected in U.S. swine

[![Docker Automated build](https://img.shields.io/docker/cloud/build/flucrew/octoflu.svg)](https://hub.docker.com/r/flucrew/octoflu/) [![DockerHub Pulls](https://img.shields.io/docker/pulls/flucrew/octoflu.svg)](https://hub.docker.com/r/flucrew/octoflu/)

## Use
Determines evolutionary origin of influenza A virus genes through inference of maximum likelihood tree and then assignment of a defined genetic clade  based on nearest neighbor determined by patristic distances.

This tool has been tested on swine H1 and H3 data (collected from 2014 to present), sequence from other serotypes, or sequence that is collected from outside North America may generate incorrect results. We suggest you use the [IRD Sequence Annotation tool](https://www.fludb.org/brc/influenza_batch_submission.spg?method=NewAnnotation&decorator=influenza) prior to running this pipeline. 

We also recommend that output from the automatic classification be interpreted conservatively, and that more comprehensive phylogenetic analyses may be required for accurate determination of evolutionary history. This pipeline generates a phylogeny using a limited set of reference sequences and annotates the queries based upon the "nearest neighbor." If query sequences are dissimilar to the annotated reference set (e.g., swine H1 sequence from the 1990s, or swine data collected in Euope or Asia) they are likely to be misclassified.

If you use this pipeline or the curated reference datasets in your work, please cite this:

Chang, J.<sup>+</sup>, Anderson, T.K.<sup>+</sup>, Zeller, M.A.<sup>+</sup>, Gauger, P.C., Vincent, A.L. (2019). octoFLU: Automated classification to evolutionary origin of influenza A virus gene sequences detected in U.S. swine. [*Microbiology Resource Announcements* 8:e00673-19](https://doi.org/10.1128/MRA.00673-19). <sup>+</sup>These authors contributed equally.

If you have problems running the pipeline, please use the Issues feature of github, or e-mail tavis.anderson@usda.gov or jennifer.chang@usda.gov directly.

We thank Jordan Angell (USDA-APHIS, Visual Services) for the design of the octoFLU logo.
 

## Input
Unaligned fasta with query sequences (e.g., strain name with protein segment identifier).

## Output
* Text output stating the query name, protein symbol, genetic clade or evolutionary lineage. 
* Text output holding the query name and top BLASTn hit. 
* Inferred maximum likelihood trees with reference gene sets and queries.

## Usage

```
bash octoFLU.sh sample_data/query_sample.fasta
```

## Installation

```
pip3 install smof
pip3 install dendropy
git clone https://github.com/flu-crew/octoFLU.git
cd octoFLU
```
If you are on linux, you can likely just use pip vs. pip3.

## Running the pipeline

You will need to have an installation of:

* [NCBI Blast](https://blast.ncbi.nlm.nih.gov/Blast.cgi?CMD=Web&PAGE_TYPE=BlastDocs&DOC_TYPE=Download), 
* [smof](https://github.com/incertae-sedis/smof),
* [mafft](https://mafft.cbrc.jp/alignment/software/), 
* [FastTree](http://www.microbesonline.org/fasttree/#Install),
* [dendropy](https://dendropy.org/downloading.html),
* and the included `treedist.py` script

Edit the paths in `octoFLU.sh` to connect `blastn`, `makeblastdb`, `smof` `mafft`, and `FastTree`.

```
# Connect your reference dataset here
REFERENCE=reference_data/reference.fa

# Connect your programs here, can use full path names
BLASTN=~/bin/blastn
MAKEBLASTDB=~/bin/makeblastdb
SMOF=~/bin/smof
MAFFT=`which mafft`
FASTTREE=~/bin/FastTree
NN_CLASS=treedist.py
```

Then run the pipeline

```
bash octoFLU.sh sample_data/query_sample.fasta
```

The output will be in a `*_Final_Output.txt` file and `*_output` folder, any trees generated will be listed and named by protein symbol, and `blast_output.txt` includes the query genes and their top BLASTn hit.

The main bottleneck is waiting for trees to run in FastTree (an installation of multi-threaded version helps). A sampling of the output is included, split by `...`.

```
bash octoFLU.sh sample_data/query.fasta

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
docker pull flucrew/octoflu
docker run -it -v ${PWD}:/data flucrew/octoflu:latest /bin/bash
```

From inside the docker image you should be able to run the pipeline. Remember to copy files to `/data` to pull them out of the docker image to your computer.

```
bash octoFLU.sh sample_data/query_sample.fasta
cp -rf query_sample.fasta_output /data/.
exit 
```

If you want to run your own dataset, hold the data in a fasta file (e.g., `mydataset/myseqs.fasta`).

```
cd mydataset
docker run -it -v ${PWD}:/data flucrew/octoflu:latest /bin/bash
bash octoFLU.sh /data/myseqs.fasta
```

After octoFLU is finished running copy data outside of docker

```
cp myseqs.fasta_output /data/.
exit
cd myseqs.fasta_output
```

## Singularity

Singularity and Docker are friends. A singularity image can be built using singularity pull. 


```
singularity pull docker://flucrew/octoflu
```

## Python and MacOS
This pipeline relies upon python3. Many MacOS computers have Python 2.7, so an update is required. The [Python website has an installer for Python 3.7](https://www.python.org/downloads/mac-osx/), if you use the package it will place python3 in /usr/local/bin/. Unfortunately, this needs you to set up an alias in your shell environment (e.g., echo "alias python=/usr/local/bin/python3.7" >> ~/.bash_profile).

The best option is to use [Homebrew](https://brew.sh).

```
brew install pyenv
pyenv install 3.7.3
pyenv global 3.7.3
pyenv version
echo -e 'if command -v pyenv 1>/dev/null 2>&1; then\n  eval "$(pyenv init -)"\nfi' >> ~/.bash_profile
```
We have also used the [anaconda distribution with python3](https://www.anaconda.com/distribution/#download-section), and the dendropy module may be installed using conda (e.g., conda install -c bioconda dendropy). [Pip](https://pip.pypa.io/en/latest/installing/ ) is a good thing to install if you don't have it.

[This is a very helpful article](https://opensource.com/article/19/5/python-3-default-macos) describing the best approach (towards the bottom) of getting python3 on your Mac


## Windows
A python script `octoFLU.py` has been provided that will run on Windows, Mac, or Linux machines with similar usage and output as the original `octoFLU.sh`. This script can be run directly in cmd.exe or through Anaconda.

```
python octoFLU.py sample_data/query_sample.fasta
```

While the dependencies are the same, pathing generally works better if it is explicit.

```
# ===== Connect your programs here, Linux style
# BLASTN = "/usr/local/bin/ncbi_blast/blastn"
# MAKEBLASTDB = "/usr/local/bin/ncbi_blast/makeblastdb"
# SMOF = "smof"
# MAFFT = "/usr/local/bin/mafft"
# FASTTREE = "/usr/local/bin/FastTree/FastTree"
# NN_CLASS = "treedist.py"
# PYTHON = "python"

# ===== Windows Style program referencing. Recommend using WHERE to find commands in cmd.exe
BLASTN = "E:/lab/tools/ncbi_blast/blastn.exe"
MAKEBLASTDB = "E:/lab/tools/ncbi_blast/makeblastdb.exe"
SMOF = "E:/Anaconda3/Scripts/smof.exe"
MAFFT = "E:/lab/tools/mafft-win/mafft.bat"
FASTTREE = "E:/lab/tools/FastTree.exe"
NN_CLASS = "treedist.py"
PYTHON = "E:/Anaconda3/python.exe"
```

Explicit pathing is needed for anything not in the Windows Path. After using `pip` to install `dendroscope` and `smof`, the path to the `smof` executable can be found using `where smof`. Input and output remain unchanged.

There has been known issues involving file encoding, while the file needs to be converted to ANSI to run correctly.

## Future Considerations
* Extend to include international evolutionary lineages.
* Reannotate the tree with NN-clades for ease of use.
* Integrate a script to combine gene assignments to a whole genome constellation descriptor.
* Annotate input sequences with gene classification, and use these designations in the inferred phylogenetic trees.
