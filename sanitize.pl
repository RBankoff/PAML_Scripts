#!/usr/bin/perl -w

my $in = $ARGV[0];

open (IN, "<", $in) or die "Couldn't open $in, $!\n";

my $header;
my $counter = 0;
my @data;


while (my $line = <IN>){
	chomp $line;
	if ($counter == 0){
		$header = $line;
	}
	else{
		push @data, $line;
	}
	$counter++;
}
close IN;

foreach $d (@data){
	my $counter = 0;
	my @local_data;
	my $local_header;
	open (INF, "<", $d) or die "Couldn't open $d, $!\n";
	while (my $line = <INF>){
        	chomp $line;
        	if ($counter == 0){
                	$local_header = $line;
        	}
		else{
             		push @local_data, $line;
		}
		$counter++;
	}
	close IN;
	my $species = (split(/\s+/,$local_header))[1];
	my $nucleotides = (split(/\s+/,$local_header))[2];
	print "Species: $species\tNucleotides: $nucleotides\n";
	$counter = 0;
	pop @ld;
	foreach $ld (@local_data){
		if ($counter % 2 == 1){
			print "species: $ld\n";
		}	
		else{
			print "seq:\n$ld\n";
			my @sequence = $ld =~ /(...)/g;	
			my $count = 0;
			foreach $se (@sequence){
				print "$count\t$se\n";
				$count++;
			}
		}
		$counter++;
	}
}
