# -*- coding: utf-8 -*-
"""
Created on Fri Jun 21 21:25:20 2019

@author: Mazeller
"""

import dendropy
from collections import OrderedDict
from operator import itemgetter   

# Print help text, including parameters
def helpText():
	print("""Usage: treedist.py -i inputtree.tre

Depends on dendrop.py, assumes newick format.
	""")
		

#Grab R from commandline arguments, or print usage
#Main execution
def main():
	argv = sys.argv[1:]

	try:
		opts, args = getopt.getopt(argv,"i:c:h",["input=","column=","help"])
	except getopt.GetoptError:
		helpText()
		sys.exit(2)
	
	#Assign local variables	
	treeFile = False
	columnAnnotated = [5]
	
	#Process command line args	
	for opt, arg in opts:
		if opt in ('-h',"help"):
			helpText()
			sys.exit()
		elif opt in ("-i", "-input"):
			treeFile = arg
		elif opt in ("-c", "-column"):
			columnAnnotated = list(map(int, arg.split(",")))

	#Error handeling for required args
	if not treeFile:
		print("Tree file is required.\n")
		helpText()
		sys.exit(2)

	#Attempt to load tree file
	tree = dendropy.Tree.get(path = treeFile, schema="newick")
	
	#Grab distances
	pdm = tree.phylogenetic_distance_matrix()
	pdma = pdm.as_data_table()

	#Iterate through col names. If missing the "tag", find the nearest neighbor that has a tag.
	for idx1, taxon1 in enumerate(tree.taxon_namespace):
		
		#Check if clade designation is present, skip if so
		defSplit = str(taxon1).split("|")
		if(len(defSplit) >= max(columnAnnotated)):	#Assumption! One delimiter (JC: can we make this more robust?) 
			continue
		print(str(taxon1))
		
		#Find the nearest neighbor with a clade label otherwise. Starting at index 1 incase 100% identity label match
		dist = pdma._data[str(taxon1)[1:-1]]
		orderedDist = OrderedDict(sorted(dist.items(), key = itemgetter(1)))
		for distance in orderedDist:
			compSplit = distance.split("|")
			if(len(compSplit) >= max(columnAnnotated)):	
				outString = ""
				for i in columnAnnotated:
					outString += compSplit[i - 1] + "\t" 	#Index shift, minus 1 (probably could use map instead of for)
				print(outString)
				break
			
if __name__ == "__main__": main()