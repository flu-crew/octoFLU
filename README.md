# nn_patristic_classifier
## Use
Determines unlabeled clades in a tree based on then earest neighbor determined by patristic distances.

## Input
Tree in either newick or nexus format containing both reference sequences and query sequences.

## Output
Text output stating the clade with the closest designation.

## Usage
Rscript nn_classifier.R path-to-tree-file
## Future Considerations
Reannotate the tree with NN-clades for ease of use.
