#!/usr/bin/perl

my $species = $ARGV[0];
my $in = $ARGV[1];
my $outfile = $ARGV[2];
my $mega_out = $ARGV[3];

my $f_counter = 0;

my @species;
my @files;
my @Final_mega;
my @final_compare;

open (SP, "<", $species) or die "no such file $species, $!\n";
while (my $line = <SP>){
	chomp $line;
	push @species, $line;

}
close SP;

open (IN, "<", $in) or die "Couldn't open $in, $!\n";

while (my $line = <IN>){
	chomp $line;
	push @files, $line;
	$f_counter++;
}
close IN;
my $seq_counter_new = 0;
foreach $f (@files){
	my @local_species;
	my @local_sequence;
	my $header;
	my $counter = 0;
	my @sequence_compare;
	my $gene_name = (split('.',$f))[0];

	open (F, "<", $f) or die "no such file $f, $!\n";
	while (my $line = <F>){
		chomp $line;
		if ($counter == 0){
			$header = $line;
			$counter++;
		}
		else{
			if ($line =~ m/[._]/){
				my $spec_name;
				$line =~ s/[.]/_/g;
				$spec_name = (split('_',$line))[1];
				push @local_species, $spec_name;
			}
			else{
				push @local_sequence, $line;
			}
		}
	}
	close F;
	$counter = 0;
	if ((scalar(@local_species)) == (scalar(@species))){
		my $complete_check = (scalar(@local_species));
		my $complete = 0;
		my $seq_count_m = 0;
		my $Mega = "Megaladapis2xMasked";
		foreach $ls (@local_sequence){
			my $mega_on = 0;
			print "Local species: " . $local_species[$seq_count_m] . "\n";
			if (($local_species[$seq_count_m]) =~ m/$Mega/ig){
				$mega_on = 1;
			}
			my @codons = $ls =~ /(...)/g;
			my @codon_check;
			foreach $c (@codons){
				if ($c !~ m/N/ig){
					if ($c !~ m/-/g){
						my $good = 1;
						push @codon_check, $good;
					}
					else{
						my $bad = 0;
						push @codon_check, $bad;
					}
				}
				else{
					 my $bad = 0;
                                         push @codon_check, $bad;
				}
			}
			my $mega_num = 0;
			my $total_codon = 0;
			if ($mega_on == 1){
				foreach $cc (@codon_check){
					$mega_num += $cc;
					$total_codon++;
				}
				print "MEGA: $mega_num\n";
				if ($mega_num >= 100){
					open (MG_OUT, ">>", $mega_out) or die "no such outfile $mega_out, $!\n";
					print MG_OUT "$mega_num\t$total_codon\t$seq_counter_new\t$f\n";
					close MG_OUT;
					push @Final_mega, $f;
				}
			}
			my $codon_result = join(',', @codon_check);
			push @sequence_compare, $codon_result;
			$seq_count_m++;
		}
	}
	my @seq_length = split(',',$sequence_compare[0]);
	my $sl = scalar(@seq_length);
	my $total_comparable = 0;
	for (my $i = 0; $i < $sl ; $i++){
		my $value = 0;
		foreach $sc (@sequence_compare){
			my $seq = (split(',',$sc))[$i];
			$value += $seq;
		}
		my $aggregate = $value / (scalar(@local_species)) ;
		$total_comparable += $aggregate;

	}
	print "$total_comparable comparable codons out of $sl codons in $f \n";
	if ($total_comparable >= 100){
		open (OUT, ">>", $outfile) or die "couldn't make outfile $outfile, $!\n";
		print OUT "$f\n";
		close OUT;
		push @final_compare, $f;
	}
	$seq_counter_new++;
}

my $fc_counter = 0;
foreach $fc (@final_compare){
	print "The following genes pass the threshold:\n";
	print "$fc\n";
	$fc_counter++;
}
print "Total passed: $fc_counter out of $fc_counter\n";

my $fm_count = 0;
foreach $FM (@Final_mega){
	$fm_count++;
}
print "Total Mega passed: $fm_count\n";

exit;


