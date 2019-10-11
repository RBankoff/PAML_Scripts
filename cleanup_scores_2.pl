#!/usr/bin/perl -w

my $input = $ARGV[0];
my $out_summary = $ARGV[1];

my @file;
my @final;

my $passed = 0 ;
my $total = 0;

open (IN, "<", $input) or die "cannot open $input: $!";
while (my $line = <IN>){
    chomp $line;
    my $filename = $line;
    $filename =~ s/\n//g;
#   print $filename . "\n";
    push @file, $filename;
}
#my $counter = 0;
my @passed_names;
my $header = 'Gene:' . "\t\t" . 'branch' . "\t" . 't' . "\t" . 'N' ."\t" . 'S' . "\t" . 'dN' . '/' . 'dS' . "\t" . 'dN' . "\t" . 'dS' . "\t" . 'N' . '*' . 'dN' . "\t" . 'S' . '*' . "dS\n";
foreach $f (@file){
	my $threshold = 100;
	my $pass = 0;
	my $name = (split(/[.]/,$f))[1];
	print "Name: $name \n";
	my @comparison;
	my @outlines;

	open (FIN, "<", $f);
	while (my $line = <FIN>){
    		chomp $line;
    		if ($line =~ m/^\d/){
			my $first = (split(/\s/,$line))[0];
			my $second = (split(/\s/,$line))[3];
			my $combo = "$first" . "..." . "$second";
			push @comparison, $combo;
			push @seconds, $second;
			print "$first" . "..." . "$second\n";
	    	}
		elsif($line =~ m/^t=/){
			my @spaced = split(/[\s\t]/, $line);
			my $check_Count = 0;
			@spaced = grep/\S/, @spaced;
			foreach $sp (@spaced){
				print "$check_Count\t$sp\n";
				$check_Count++;		
			}
			my $t = $spaced[1];
			my $S = $spaced[3];
			my $N = $spaced[5];
			my $dn_ds = $spaced[7];
			my $dN = $spaced[10];
			my $dS = $spaced[13];
			my $n_dN = ($N * $dN);
			my $s_dS = ($S * $dS);
			my $outline = "$t\t$N\t$S\t$dn_ds\t$dN\t$dS\t$n_dN\t$s_dS";
			push @outlines, $outline;
		
		}
		elsif($line =~/^After/){
			    my @spaced = split(/[\s\t]/, $line);
                        my $check_Count = 0;
                        @spaced = grep/\S/, @spaced;
                        foreach $sp (@spaced){
                                print "$check_Count\t$sp\n";
                                $check_Count++;
                        }
			$test_length = $spaced[3];
			if ($test_length >= $threshold){
				$pass++;
			}

		}
	
	}
	close FIN;
	my $count = 0;
	if ($pass > 0){
		my $head_name = $name . "\n";
		push @final, $head_name;
		foreach $comp (@comparison){
			my $local_out = $outlines[$count];
			print "$name\t$comp\t$local_out\n";
			$to_final = "$name\t$comp\t$local_out\n";
			push @final, $to_final;
			$count++;
		}
		push @passed_names, $name;
		$passed++;
	}
$total++;
}
open (OUTS, ">", $out_summary);
print OUTS "$header";
foreach $tf (@final){
	print OUTS "$tf";
}
close OUTS;

print "Passed: $passed out of $total\n";
exit;
	
