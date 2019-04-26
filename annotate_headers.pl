#! /usr/bin/env perl
# Auth: Jennifer Chang
# Date: 2019/04/26

use strict;
use warnings;

my %annot;

my $fn1=$ARGV[0];  # Annotation
my $fn2=$ARGV[1];  # Fasta File
my @fields;

my $fh;
open($fh, '<:encoding(UTF-8)', $fn1) or die "Could not open file '$fn1' $1";

while(<$fh>){
    chomp;
    @fields=split("\t",$_);
    if((scalar @fields)>2){
	# annot{strain} = seg|clade
	$annot{$fields[0]}=join("|",@fields[1..(scalar @fields)-1]);
    }
}

close($fh);

open($fh, '<:encoding(UTF-8)', $fn2) or die "Could not open file '$fn2' $1";

my $strain="";
my $original="";
while(<$fh>){
    if(/>(.+)/){
	$original=$1;
	$strain=$1;
	$strain=~s/\|/_/g;
	print ">$original|$annot{$strain}\n"
    }else{
	print;
    }
}

close($fh);
