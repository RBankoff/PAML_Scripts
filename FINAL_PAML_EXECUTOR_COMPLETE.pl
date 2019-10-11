#!/usr/bin/perl -w
use FileHandle;
use Expect;

# Creates four variable filehandles for use in looped I/O functions
$fh = FileHandle->new();
$fh1 = FileHandle->new();
$fh2 = FileHandle->new();
$fh3 = FileHandle->new();

# Calls the two folders containing input .nuc & .ctl files; necessary for the program to function
$inputfolder = $ARGV[0];
$controlfolder = $ARGV[1];

# Specifies an output directory for the processed output files from PAML; optional
$outputfolder = $ARGV[2];

# Specifies whether or not to move PAML processed files into output directory named by ARGV[2]; optional
$Move = $ARGV[3];

# Makes optional output directory
mkdir $outputfolder;

# Assigns the full pathnames of all files specified in the first and second command line arguments to two arrays 
@nameholder = <$inputfolder/*>;
@controlholder = <$controlfolder/*>;

print "NOTE:Make sure the \"dat\" directory is in the working directory and that the parameters specified in the control files are correct before running!\n\n";

# Removes the pathname from each of the input directory's files (e.g. RunD/A4GNT.nuc becomes A4GNT.nuc in the new array)
foreach $nh (@nameholder){
	@prefixed = split(/\//, $nh);
	push (@fixed, $prefixed[1]);
}

my @stop = (TAA, TAG, TGA);
my @species_keep = ("Propithecus", "Lepilemur", "micMur1", "Eulemur", "Megaladapis2xMasked", "Daubentonia", "gorGor1", "panTro2", "hg19");
my %S_keep = map {$_ => 1} @species_keep;
# Until there are no more files to process from the input directory 
while (scalar(@nameholder) > 0){
	
	# For each input file
	for ($nameholder[0]){
		
		# Screen out random directory name that ended up in cluster directory, can be removed without breaking anything as long as the else statement below it is as well 
		unless ($nameholder[0] =~ /Users/){
			my $outseq = $fixed[0];
			
			# Opens the nuclear phylip formatted (.nuc suffix) input file to read 
			open ($fh, "<", $nameholder[0]) or die "Could not open input .nuc seqfile, $!\n";
			# Creates and opens the output file to write in the working directory 
			open ($fh1, ">", $outseq) or die "Could not create .nuc output file, $!\n";
			
			# Reads in data to the .nuc outfile in the working directory
			my $bs_count = 0;
			my $cs_count = 0;
			my @lns;
			while (my $line = <$fh>){
				chomp $line;
				if ($bs_count == 0){
					print $fh1 "$line\n";
					$bs_count++;
				}
				else{
					if (exists($S_keep{$line})){
						print "L: $line\n";
							push @lns, $line;
							$cs_count++;
					}
					else{

							my $precodons = $line;
							print "PRECODON: $precodons\n";
							my @codons;
							for(my $i = 0; $i < length($precodons); $i+=3){
								my $local_codon = substr($precodons, $i, 3);
								if (($local_codon !~ /TAA/) && ($local_codon !~ /TAG/) && ($local_codon !~ /TGA/)){
									push @codons, $local_codon;
								}
								else{
									my $blanks = "NNN";
									push @codons, $blanks;
								}
							}
							my $final_line = join('', @codons);
							my $BSM = ($cs_count);
							print "BSM: $BSM\n";
							my $local_name = $lns[$cs_count - 1];
							print "$local_name\n";
							print $fh1 "$local_name  $final_line\n";
					}
				}		
			}
			
			# Closes both files
			close $fh;
			close $fh1;
			print "EEE\n";
			my $outctl = "codeml.ctl";
			
			# Opens the .ctl input control file in the specified control directory to read
			open ($fh2, "<", $controlholder[0]) or die "Could not open input .ctl control file, $!\n";
			# Creates and opens the .ctl output file in the working directory
			open ($fh3, ">", $outctl) or die "Could not create .ctl output file, $!\n";
			
			# Reads data to the .ctl outfile in the working directory
			while (<$fh2>){
				my $line = $_;
				print $fh3 $line;
			}
			
			# Closes both files
			close $fh2;
			close $fh3;
			my $timeout = 5;
#			print "JJJ\n";
			# Runs the CodeML program included in PAML v4.8 on the newly created .nuc and .ctl control files (NOTE: Make sure the "dat" directory is in the working directory
			# and that the parameters specified in the control files are correct before running.
			$command = Expect->spawn("./codeml") or die "Couldn't start program: $!\n";
			$command->expect($timeout, ['Press Enter to continue']); 
			$command->send('\r');
			print "QQQ\n";
			# Removes the two temporary files created in the working directory above
			`rm $outseq`;
			`rm $outctl`;
			
			# BELOW: optional step to move all output files to output directory specified in the third command line argument, if given; off by default
			if (scalar(@ARGV) == 4){
				
				# If "1" is the last of 4 arguments passed to the command line
				if ($Move == 1){
					
					# Move processed PAML outfile to specified directory
					`mv out.* $outputfolder`;
				}
			}
			
			# Removes all used values so the loop continues to process new files from the input directories
			shift @nameholder;
			shift @controlholder;
			shift @fixed;
			print "FFF\n";
		}
		
		# Else skips over random directory name by shifting the arrays with its values
		else{
			shift @nameholder;
			shift @controlholder;
			shift @fixed;
		}
	}
}
