FROM ubuntu:18.04

RUN apt-get update && apt-get install -y git && apt-get -y install mafft
RUN apt-get install -y ncbi-blast+ && apt-get install -y curl && apt-get install -y python3-pip
RUN git clone "https://github.com/flu-crew/octoFLU.git" octoFLU
# RUN git clone "https://github.com/incertae-sedis/smof.git" smof
RUN pip3 install smof
RUN pip3 install dendropy
#RUN DEBIAN_FRONTEND=noninteractive apt-get install -y r-base && echo "install.packages(\"ape\", repos=\"https://cran.rstudio.com\")" | R --no-save
WORKDIR /octoFLU/
RUN curl -O http://www.microbesonline.org/fasttree/FastTree.c
RUN gcc -O3 -finline-functions -funroll-loops -Wall -o FastTree FastTree.c -lm
RUN gcc -DOPENMP -fopenmp -O3 -finline-functions -funroll-loops -Wall -o FastTreeMP FastTree.c -lm
#RUN apt-get install -y fasttree
RUN mv FastTree /usr/bin/FastTree
RUN mv FastTreeMP /usr/bin/FastTreeMP
RUN bash octoFLU.sh sample_data/query_sample.fasta
RUN mv query_sample.fasta_output old_out

# RUN ln -s ../smof/smof.py .
ENV PATH=/:$PATH

CMD ["ls"]
# CMD ["./octoFLU.sh sample_data/query_sample.fasta"]

LABEL author="Jennifer Chang"
LABEL last-update="2019-06-21"
