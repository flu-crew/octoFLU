#Michael Zeller 3/12/2019
#Input: Tree file (newick/nexus). Tips should be labeled as name|clade. Query sequences should be 
# name only, without '|
#Output: Nearest neighbor clade assignment based on patristic tree distance

#Load needed libraries
library(ape)

#Request tree file form user (switch to arg?)
treeFile <- readline(prompt="Path to tree file: ")

#Load user specified tree file
tree<-read.tree(treeFile)

#Get patristic distance matrix
pdm <-cophenetic(tree)

#Iterate through col names. If missing the "tag", find the nearest neighbor that has a tag.
taxa <- colnames(pdm)
for (i in 1:length(taxa))
{
  #Check if clade designation is present, skip if so
  defSplit = strsplit(taxa[i],"|", fixed=TRUE)
  if(length(defSplit[[1]]) >=2)       #Assumption! One delimiter
  {
    next
  }
  
  #Find the nearest neighbor with a clade label otherwise. Starting at index 1 incase 100% identity label match
  orderedList = sort(pdm[,i])
  for (j in 1:length(orderedList))
  {
    compSplit = strsplit(names(orderedList[j]),"|", fixed=TRUE)
    if(length(compSplit[[1]]) >=2)      
    {
      print(paste(taxa[i],"is closest to ", compSplit[[1]][2], sep = " "))
      break
    }
  }
}
