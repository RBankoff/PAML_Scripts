#!/usr/bin/perl
use strict;
use warnings;

# Converts all fasta files in a directory to nuc files (phylip with up 30 letter taxa names) for PAML. Use option "nucleotides" or "codons" to list corresponding number in topline of nuc file. codonsGC option add "GC" to codon version. Blank option defaults to nucleotides.

my $PAML_type = $ARGV[0];
my $fastas = $ARGV[1];
open (IN, "<", $fastas) or die "couldn't open $fastas, $!\n";
my @fastas;
while (my $line = <IN>){
	chomp $line;
	my @file = split('/', $line);
	my $length = scalar(@file);
	my $file_t = $file[($length - 1)];
	print "$file_t\n";
	push @fastas, $file_t;
}
close IN;

foreach my $fasta(@fastas){
#	chomp $fasta;	
	print "\nfasta file: $fasta loaded \n";
	my @split_fasta = split (/\./, $fasta);
	my $file_name = "$split_fasta[0].". "$split_fasta[1]";	
	my $nuc = "$file_name." . "nuc";
	my $species_name;
	my $sequence;
	my $line_count = 0;
	my $taxa_count = 0;
	my $nucleotide_count = 0;	
	
	open (IN, "<", $fasta) or die "$fasta did not load for counting, guy. You should really try harder."; 
	open (OUT, ">", $nuc);
	
	while (my $line = <IN>){
		chomp $line;
		foreach ($line){
			if ($line =~ m/(^>)(.+)/){
				$taxa_count++; 
				$line_count++;
			}
			elsif ($line !~ m/^>/){
				my $nucleotides = length ($line);
				$nucleotide_count = ($nucleotide_count + $nucleotides);
				$line_count++;
			} 
		}
	}
	my $sites = ($nucleotide_count /= $taxa_count);
	my $sites2 = $sites;
	my $codons = ($sites2 /= 3);

	if (not defined $PAML_type){
		print OUT "   $taxa_count $sites\n";
	}
	elsif ($PAML_type eq "nucleotide"){
		print OUT "   $taxa_count $sites\n";
	}
	elsif ($PAML_type eq "codonGC"){
		print OUT "  $taxa_count $codons GC\n";	
	}
	elsif ($PAML_type eq "codon"){
		print OUT "  $taxa_count $codons\n"
		}
	else{
		print "***ERROR*** Type of PAML run not defined. Add nucleotide, codon, or codonGC after fa2nuc_batch.pl ***ERROR***\n" 
	}
	close (IN);

	open (IN, "<", $fasta) or die "$fasta did not load for sequence conversion, guy. You should really try harder."; 
	while (my $line = <IN>){
		chomp $line;
		foreach ($line){
			if ($line =~ m/(^>)(.+)/){
				$species_name = "$2  ";
				print OUT "$species_name\n";
			}
			elsif ($line !~ m/^>/){
				$sequence = $line;
				print OUT "$sequence\n";
			} 
		}
	}
	print "nuc file: $nuc created\n";
	print "$taxa_count taxa, $line_count lines of text, and $sites nucleotides ($codons codons) per sequence \n\n";
}
exit();

