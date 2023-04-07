#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;

my ($inputFile, $storageDir, $outputFile);

&GetOptions("inputFile=s"=> \$inputFile,
            "storageDir=s"=> \$storageDir,
            "outputFile=s"=> \$outputFile);

open(my $data, '<', $inputFile) || die "Could not open file $inputFile: $!";
open(OUT,">$outputFile");
while (my $line = <$data>) {
    chomp $line;
    if ($line =~  /^eupath/) { 
        my ($eupath,$project,$proteomeName,$build,$abbrev) = split(/\,/, $line);
        `wget "https://$project.org/common/downloads/Current_Release/$proteomeName/fasta/data/$project-${build}_${proteomeName}_AnnotatedProteins.fasta" --output-document ./$abbrev.fasta --tries=5`;
	if (-e "/storage/$abbrev.fasta") {
            my $needsUpdate = `diff /storage/$abbrev.fasta ./$abbrev.fasta -q`;
            if (length($needsUpdate) != 0) {
	        `cp $abbrev.fasta /storage`;
	        print OUT "$abbrev\n";
            }
	}
	else {
	    `cp $abbrev.fasta /storage/`;
	    print OUT "$abbrev\n";
        }
    }
    else {
        my ($uniprot,$proteomeId,$abbrev) = split(/\,/, $line);
        `wget "https://rest.uniprot.org/uniprotkb/stream?compressed=true&format=fasta&query=%28%28proteome%3A${proteomeId}%29%29"--tries=5 --output-document ./$abbrev.fasta.gz`;
	if (-e "/storage/$abbrev.fasta.gz") {
            my $needsUpdate = `diff /storage/$abbrev.fasta ./$abbrev.fasta -q`;	    
            if (length($needsUpdate) != 0) {
	        `cp $abbrev.fasta /storage`;
	        print OUT "$abbrev\n";
            }
	}
	else {
	    `cp $abbrev.fasta.gz /storage/`;
	    print OUT "$abbrev\n";
        }
    }
}
