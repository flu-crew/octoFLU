#! /usr/bin/env Rscript
# Auth: Jennifer Chang
# Date: 2019/03/15

# Libraries
library(reshape2)

# Read in data
infile <- ""
args <- commandArgs(trailingOnly=TRUE)

if(length(args) < 1) {
  print("Usage: Rscript mergeGC.R Final_Output_file")
  quit()
} else {
  infile <- args[1]
}
my.data <- read.delim(infile, header=FALSE, stringsAsFactors = FALSE)

# Combine US and Global clade to one column
ha <- c("H1", "H3")
my.data$V3[my.data$V2 %in% ha] <- paste(my.data$V3[my.data$V2 %in% ha], my.data$V4[my.data$V2 %in% ha], sep = "|")

tt <- dcast(my.data, V1 ~ V2, value.var="V3")
tt <- tt[order(tt$V1),c("V1","H1","H3","N1","N2","PB2","PB1","PA","NP","M","NS")]
tt[is.na(tt)] <- "-"

write.table(tt, file = "Merge_Attempt.txt", row.names = FALSE, quote = FALSE, sep = "\t")
