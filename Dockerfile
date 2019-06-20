FROM ubuntu:18.04

     RUN apt-get -y update && apt-get install -y git && apt-get -y install mafft && apt-get -y install emacs
     RUN apt-get -y install ncbi-blast+ && apt-get -y install curl
     RUN git clone "https://github.com/flu-crew/octoFLU.git" octoFLU
     RUN git clone "https://github.com/incertae-sedis/smof.git" smof
     RUN DEBIAN_FRONTEND=noninteractive apt-get install -y r-base && echo "install.packages(\"ape\", repos=\"https://cran.rstudio.com\")" | R --no-save
     WORKDIR /octoFLU/
     RUN curl -O http://www.microbesonline.org/fasttree/FastTree.c
     RUN gcc -O3 -finline-functions -funroll-loops -Wall -o FastTree FastTree.c -lm
     RUN gcc -DOPENMP -fopenmp -O3 -finline-functions -funroll-loops -Wall -o FastTreeMP FastTree.c -lm
     RUN ln -s ../smof/smof.py .
     ENV PATH=/:$PATH
     
     CMD ["ls"]
#     CMD ["./pipeline.sh sample_data/query_sample.fasta"]

     LABEL author="Jennifer Chang"
     LABEL last-update="2019-06-14"
