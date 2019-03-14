FROM ubuntu:18.04

     RUN apt-get -y update && apt-get install -y git
     RUN git clone https://github.com/j23414/nn_patristic_classifier.git
     RUN DEBIAN_FRONTEND=noninteractive apt-get install -y r-base && echo "install.packages(\"ape\", repos=\"https://cran.rstudio.com\")" | R --no-save
     WORKDIR /nn_patristic_classifier/output 
     ENV PATH=/:$PATH
#    CMD ["ln -s cavatica/data/test/*.tsv ."]
     CMD ls
#     CMD ["../../code/script.sh"]
     	 
	 LABEL author="Jennifer Chang"
	 LABEL last-update="2019-03-14"
