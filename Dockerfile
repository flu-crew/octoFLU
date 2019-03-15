FROM ubuntu:18.04

     RUN apt-get -y update && apt-get install -y git && apt-get -y install mafft && apt-get -y install emacs
     RUN apt-get -y install ncbi-blast+ && apt-get -y install curl
     RUN git clone "https://d4a3ca95813e5b2a64cad21ea8251958eaa674d2@github.com/j23414/nn_patristic_classifier.git" nn_patristic_classifier
     RUN git clone https://github.com/incertae-sedis/smof.git
     RUN DEBIAN_FRONTEND=noninteractive apt-get install -y r-base && echo "install.packages(\"ape\", repos=\"https://cran.rstudio.com\")" | R --no-save
     WORKDIR /nn_patristic_classifier/
     RUN curl -O http://www.microbesonline.org/fasttree/FastTree.c
     RUN gcc -O3 -finline-functions -funroll-loops -Wall -o FastTree FastTree.c -lm
     RUN gcc -DOPENMP -fopenmp -O3 -finline-functions -funroll-loops -Wall -o FastTreeMP FastTree.c -lm
     RUN ln -s ../smof/smof.py .
     ENV PATH=/:$PATH
#    CMD ["ln -s cavatica/data/test/*.tsv ."]
     CMD ls
#     CMD ["../../code/script.sh"]
     	 
	 LABEL author="Jennifer Chang"
	 LABEL last-update="2019-03-14"
