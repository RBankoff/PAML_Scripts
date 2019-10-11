#!/usr/bin/perl -w


my $input = $ARGV[0];
my $out = $ARGV[1];
mkdir $out;
my @file;


open (IN, "<", $input) or die "cannot open $input: $!";
while (my $line = <IN>){
    chomp $line;
    my $filename = (split("\t", $line))[3];
    $filename =~ s/\n//g;
    push @file, $filename;
}

my @species_keep = ("Propithecus", "Lepilemur", "micMur1", "Eulemur", "Megaladapis2xMasked", "Daubentonia", "gorGor1", "panTro2", "hg19");
my %S_keep = map {$_ => 1} @species_keep;

my $total_count = 0;
open (OUTLIST, ">", "Out_list.txt") or die "Couldn't open outfile Out_list.txt, $!\n";
foreach $f (@file){
	my @data;
	my $header;
	my $header_count = 0;

	open(INT, "<", $f);
	while (my $line = <INT>){
    		chomp $line;
    		if ($header_count == 0){
    			$header = $line; 
    			$header_count++;
    		}
    		else{
    			push @data, $line;
    		}
    	}
	close INT;
	my @species;
	my @seqs;
   	$header_count = 0;
    	foreach $d (@data){
    		if ($header_count % 2 == 0){
			my $variable = (split(/[._]/, $d))[1];
    			$variable =~ s/\s+//g;
			push @species, $variable;
    		}
    		else{
    			push @seqs, $d;
    		}
    		$header_count++;
    	}
	$header_count = 0;
	my $preoutname = (split(/[.]/,$f))[0];
	$preoutname .= ".reduced.fa.nuc";
	print "PRE: $preoutname\n";
	print OUTLIST "$preoutname\n";
	my @split_head = split(/\s/,$header);
	my $codon_ct = $split_head[3];
	my $rejoined_header = "  " . 9 . " " . $codon_ct . "\n";
	open (LOCOUT, ">", $preoutname) or die "couldn't open $preoutname for output, $!\n";
	print LOCOUT "$rejoined_header\n";
	foreach $s (@species){
		$total_count++;
		if (exists($S_keep{$s})){
			print LOCOUT "$s\n";
			print LOCOUT "$seqs[$header_count]\n";
		}
		$header_count++;
    	}
	close LOCOUT;
	`mv $preoutname $out/`;
	print "$total_count\n";
}
close OUTLIST;
