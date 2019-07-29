import os
import sys
import subprocess
from shutil import which
from shutil import copyfile

# ===== Input and Output
inputFile = sys.argv[1]
baseName = os.path.basename(inputFile)
outDir = baseName + "_output"

#print(inputFile)
#print(outDir)

# ===== Create Output Directory if not already created
#[ -d ${OUTDIR} ] || mkdir ${OUTDIR} 
if not os.path.exists(outDir):
	os.mkdir(outDir)
else:
	sys.exit("Directory " + outDir + " already exists")

# ===== Connect your reference here
reference = "reference_data/reference.fa"

# ===== Connect your programs here, Linux style
BLASTN = "/Users/michael.zeller/ncbi_blast/blastn"
MAKEBLASTDB = "/Users/michael.zeller/ncbi_blast/makeblastdb"
SMOF = "smof"
MAFFT = "/usr/local/bin/mafft"
FASTTREE = "/Users/michael.zeller/FastTree/FastTree"
NN_CLASS = "treedist.py"
PYTHON = "python"

# ===== Windows Style program referencing
# BLASTN = "E:/lab/tools/ncbi_blast/blastn.exe"
# MAKEBLASTDB = "E:/lab/tools/ncbi_blast/makeblastdb.exe"
# SMOF = "E:/Anaconda3/Scripts/smof.exe"
# MAFFT = "E:/lab/tools/mafft-win/mafft.bat"
# FASTTREE = "E:/lab/tools/FastTree.exe"
# NN_CLASS = "treedist.py"
# PYTHON = "E:\Anaconda3\python.exe"

# ===== Uncomment and connect your programs here using full path names
# BLASTN=/usr/local/bin/blastn
# MAKEBLASTDB=/usr/local/bin/makeblastdb
# SMOF=/usr/local/bin/smof
# MAFFT=/usr/local/bin/mafft
# FASTTREE=usr/local/bin/FastTree
# NN_CLASS=nn_classifier.R
# ANNOT_FASTA=annotate_headers.pl

# ===== Check if dependencies are available, quit if not

# Attempt to use python3, but if not there check if python is python3
if sys.version_info[0] < 3:
    system.exit("Must be using Python 3")

"""
# Attempt to use multiprocessor version, but if not there use single processor
if [ -z `which FastTreeMP` ]; then
    FASTTREE=FastTree
else
    FASTTREE=FastTreeMP
fi
echo $FASTTREE
"""

# Formal check of dependencies
Err = 0
if which(BLASTN) is None:
	print("blastn      .... need to install")
	Err = 1
else:
	print("blastn      .... good")

if which(MAKEBLASTDB) is None:
	print("makeblastdb      .... need to install")
	Err = 1
else:
	print("makeblastdb      .... good")
	
if which(MAFFT) is None:
	print("mafft      .... need to install")
	Err = 1
else:
	print("mafft      .... good")
	
if which(FASTTREE) is None:
	print("fastTree      .... need to install")
	Err = 1
else:
	print("fastTree      .... good")
	
if which(SMOF) is None:
	print("smof      .... need to install")
	Err = 1
else:
	print("smof      .... good")
	
if (Err == 1):
    sys.exit("Link or install any of your 'need to install' programs above")
	

# ===== Remove pipes in query header
with open(inputFile, 'r') as file :
  fileData = file.read()
fileData = fileData.replace('|', '_')
with open(baseName + ".clean", 'w') as file:
  file.write(fileData)
  
# ===== Create your Blast Database
# ${MAKEBLASTDB} -in ${REFERENCE} -parse_seqids -dbtype nucl      # requires no spaces in header
subprocess.call([MAKEBLASTDB,"-in",reference,"-dbtype","nucl"])

# ===== Search your Blast Database
subprocess.run([BLASTN,"-db",reference,"-query",baseName + ".clean","-num_alignments","1","-outfmt","6","-out",outDir + "/blast_output.txt"], check = True)

print("... results in " + outDir + "/blast_output.txt")

# ===== Split out query into 8 segments
H1list = []
H3list = []
N1list = []
N2list = []
PB2list = []
PB1list = []
PAlist = []
NPlist = []
Mlist = []
NSlist = []

with open(outDir + "/blast_output.txt", 'r') as file :
	for line in file:
		fields = line.strip().split()
		if("|H1|" in fields[1]):
			H1list.append(fields[0])
		if("|H3|" in fields[1]):
			H3list.append(fields[0])
		if("|N1|" in fields[1]):
			N1list.append(fields[0])
		if("|N2|" in fields[1]):
			N2list.append(fields[0])
		if("|PB2|" in fields[1]):
			PB2list.append(fields[0])
		if("|PB1|" in fields[1]):
			PB1list.append(fields[0])
		if("|PA|" in fields[1]):
			PAlist.append(fields[0])
		if("|NP|" in fields[1]):
			NPlist.append(fields[0])
		if("|M|" in fields[1]):
			Mlist.append(fields[0])
		if("|NS|" in fields[1]):
			NSlist.append(fields[0])
			
with open(outDir + "/H1.ids", 'w') as file:
	file.writelines(["%s\n" % item  for item in H1list])
with open(outDir + "/H3.ids", 'w') as file:
	file.writelines(["%s\n" % item  for item in H3list])
with open(outDir + "/N1.ids", 'w') as file:
	file.writelines(["%s\n" % item  for item in N1list])
with open(outDir + "/N2.ids", 'w') as file:
	file.writelines(["%s\n" % item  for item in N2list])
with open(outDir + "/PB2.ids", 'w') as file:
	file.writelines(["%s\n" % item  for item in PB2list])
with open(outDir + "/PB1.ids", 'w') as file:
	file.writelines(["%s\n" % item  for item in PB1list])
with open(outDir + "/PA.ids", 'w') as file:
	file.writelines(["%s\n" % item  for item in PAlist])
with open(outDir + "/NP.ids", 'w') as file:
	file.writelines(["%s\n" % item  for item in NPlist])
with open(outDir + "/M.ids", 'w') as file:
	file.writelines(["%s\n" % item  for item in Mlist])
with open(outDir + "/NS.ids", 'w') as file:
	file.writelines(["%s\n" % item  for item in NSlist])

ARR = ["H1", "H3", "N1", "N2", "PB2", "PB1", "PA", "NP", "M", "NS"]
   
# Fast part, separating out the sequences and adding references
for segment in ARR:
	print(segment)
	segmentFile = outDir + "/" + segment + ".ids"
	if os.path.isfile(segmentFile):
		#Translators note: import smof, do smoffy things would be better
		subprocess.run(SMOF + " grep -Xf " + outDir + "/" + segment + ".ids " + baseName + ".clean" + " > " + outDir + "/" + segment + ".fa", shell = True, check = True)
		subprocess.run(SMOF + " grep \"|" + segment + "|\" reference_data/reference.fa >> query_sample.fasta_output/" + segment + ".fa", shell = True, check = True) 
		#Cannot get same style to work
		#subprocess.check_output([SMOF,"grep","\"|" + segment + "|\"", reference, ">>", outDir + "/" + segment + ".fa"], shell = True)
	#os.remove(outDir + "/" + segment + ".ids")
	
# Slow part, building the alignment and tree; slower from shell spin ups
for segment in ARR:
	print(segment)
	segmentFile = outDir + "/" + segment + ".fa"
	if os.path.isfile(segmentFile):
		#subprocess.check_output([MAFFT, "--auto", "--reorder", outDir + "/" + segment + ".fa", ">", outDir + "/" + segment + "_aln.fa"], shell = True)
		subprocess.check_output(MAFFT + " --auto --reorder " + outDir + "/" + segment + ".fa > " + outDir + "/" + segment + "_aln.fa", shell = True)
		#subprocess.check_output([FASTTREE,"-nt","-gtr","-gamma",outDir + "/" + segment + "_aln.fa",">",outDir + "/" + segment + ".tre"], shell = True) # can drop -gtr -gamma for faster results
		subprocess.check_output(FASTTREE + " -nt -gtr -gamma " + outDir + "/" + segment + "_aln.fa" + " > " + outDir + "/" + segment + ".tre", shell = True) # can drop -gtr -gamma for faster results
		
	#os.remove(outDir + "/" + segment + ".fa")

# Fast again, pull out clades
	finalOutputFile = outDir + "/" + segment + "_Final_Output.txt"
	if os.path.isfile(finalOutputFile):
		os.remove(finalOutputFile)
		
#touch ${BASENAME}_Final_Output.txt
# Annotations are based upon reading reference set deflines. For example, H1 genes have
# the H1 gene at pipe 5, the US HA clade at pipe 1, and the Global HA clade at pipe 8.
# These positions may be modified, or extended, to return any metadata required.
subprocess.check_output(PYTHON + " " + NN_CLASS + " " + "-i" + outDir + "/H1.tre -c 5,1,8 > " + baseName + "_Final_Output.txt", shell = True)
subprocess.run(PYTHON + " " + NN_CLASS + " " + "-i" + outDir + "/H3.tre -c 5,1,8 >> " + baseName + "_Final_Output.txt", shell = True, check = True)
subprocess.run(PYTHON + " " + NN_CLASS + " " + "-i" + outDir + "/N1.tre -c 5,1 >> " + baseName + "_Final_Output.txt", shell = True, check = True)
subprocess.run(PYTHON + " " + NN_CLASS + " " + "-i" + outDir + "/N2.tre -c 5,1 >> " + baseName + "_Final_Output.txt", shell = True, check = True)
subprocess.run(PYTHON + " " + NN_CLASS + " " + "-i" + outDir + "/PB2.tre -c 5,1 >> " + baseName + "_Final_Output.txt", shell = True, check = True)
subprocess.run(PYTHON + " " + NN_CLASS + " " + "-i" + outDir + "/PB1.tre -c 5,1 >> " + baseName + "_Final_Output.txt", shell = True, check = True)
subprocess.run(PYTHON + " " + NN_CLASS + " " + "-i" + outDir + "/PA.tre -c 5,1 >> " + baseName + "_Final_Output.txt", shell = True, check = True)
subprocess.run(PYTHON + " " + NN_CLASS + " " + "-i" + outDir + "/NP.tre -c 5,1 >> " + baseName + "_Final_Output.txt", shell = True, check = True)
subprocess.run(PYTHON + " " + NN_CLASS + " " + "-i" + outDir + "/M.tre -c 5,1 >> " + baseName + "_Final_Output.txt", shell = True, check = True)
subprocess.run(PYTHON + " " + NN_CLASS + " " + "-i" + outDir + "/NS.tre -c 5,1 >> " + baseName + "_Final_Output.txt", shell = True, check = True)

copyfile(baseName + "_Final_Output.txt", outDir + "/" + baseName + "_Final_Output.txt")

print("==== Final results in  " + baseName + "_Final_Output.txt")
print("alignment and tree files in the '" + outDir + "' folder")
#print("Tree files are listed below: ")
#ls -ltr ${OUTDIR}/*.tre

