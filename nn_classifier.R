#! /usr/bin/env Rscript
# Auth: Michael Zeller 3/12/2019
# Input: Tree file (newick/nexus). Tips should be labeled as name|clade. Query sequences should be 
# name only, without '|
# Output: Nearest neighbor clade assignment based on patristic tree distance

#Load needed libraries
library(ape)

#Grab R from commandline arguments, or print usage
treeFile <- ""
args <- commandArgs(trailingOnly=TRUE)

if(length(args) < 1) {
  print("Usage: Rscript nn_prototype.R path-to-tree-file")
  quit()
} else {
  treeFile <- args[1]
  if(length(args)>1){ # Allow user to specify column
    col_annotated=as.numeric(args[-1]) # all but first, can pull out multiple annotations
  }else{
    col_annotated=2
  }
}

#Load user specified tree file
tree<-read.tree(treeFile)

#Get patristic distance matrix
pdm <-cophenetic(tree)

#Iterate through col names. If missing the "tag", find the nearest neighbor that has a tag.
taxa <- colnames(pdm)
for (i in 1:length(taxa)) {
  #Check if clade designation is present, skip if so
  defSplit = strsplit(taxa[i],"|", fixed=TRUE)
  if(length(defSplit[[1]]) >=min(col_annotated)) {       #Assumption! One delimiter (JC: can we make this more robust?)
    next
  }
  
  #Find the nearest neighbor with a clade label otherwise. Starting at index 1 incase 100% identity label match
  orderedList = sort(pdm[,i])
  for (j in 1:length(orderedList)) {
    compSplit = strsplit(names(orderedList[j]),"|", fixed=TRUE)
    
    if(length(compSplit[[1]]) >=min(col_annotated)) {
      out_str=taxa[i]
      for (ca in col_annotated){  # print out each column of annotations
        out_str=paste(out_str,compSplit[[1]][ca], sep='\t')
      }
      cat(out_str,"\n")
      #print(paste(taxa[i],"is closest to ", compSplit[[1]][col_annotated], sep = " "))
      break
    }
  }
}
