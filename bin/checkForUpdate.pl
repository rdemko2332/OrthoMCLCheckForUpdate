#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;

my ($inputFile, $storageDir, $outputFile, $ebiFtpUser, $ebiFtpPassword);

&GetOptions("inputFile=s"=> \$inputFile,
            "storageDir=s"=> \$storageDir,
            "outputFile=s"=> \$outputFile,
            "ebiFtpUser=s"=> \$ebiFtpUser,
            "ebiFtpPassword=s"=> \$ebiFtpPassword);

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
    elsif ($line =~  /^Ebi/) {
        my ($downloadType,$organismName,$build,$project) = split(/\,/, $line);
	`wget --ftp-user ${ebiFtpUser} --ftp-password ${ebiFtpPassword} -O ${organismName}.sql.gz ftp://ftp-private.ebi.ac.uk:/EBIout/${build}/coredb/${project}/${organismName}.sql.gz`;

	if (-e "/storage/$organismName.sql.gz") {
            my $needsUpdate = `diff /storage/$organismName.sql.gz ./$organismName.sql.gz -q`;

	    if (length($needsUpdate) != 0) {
	        `cp ${organismName}.sql.gz /storage/${organismName}.sql.gz`;
	        print OUT "$organismName\n";
            }
        }

	else {
	    `cp ${organismName}.sql.gz /storage/${organismName}.sql.gz`;
	    print OUT "$organismName\n";
        }
    }
    else {
	die "Line needs to start with Uniprot or Ebi\n";
    }
}
