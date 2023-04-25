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

    if ($line =~  /^Uniprot/) { 
        my ($downloadType,$proteomeId,$abbrev) = split(/\,/, $line);
	`wget "https://rest.uniprot.org/uniprotkb/stream?compressed=true&format=fasta&query=proteome%3A${proteomeId}" --tries=5 --output-document ./$abbrev.fasta.gz`;

        `gunzip $abbrev.fasta.gz`;
	`grep ">" $abbrev.fasta > newHeaders.txt`;
	`sort newHeaders.txt -o sortedHeaders.txt`;
	
	if (-e "/storage/$abbrev.txt") {
            my $needsUpdate = `diff /storage/$abbrev.txt ./sortedHeaders.txt -q`;

	    if (length($needsUpdate) != 0) {
	        `cp sortedHeaders.txt /storage/$abbrev.txt`;
	        print OUT "$abbrev\n";
            }
        }

	else {
	    `cp sortedHeaders.txt /storage/$abbrev.txt`;
	    print OUT "$abbrev\n";
        }
    }
}
