#!/usr/bin/perl -w
#use strict;
#use FileHandle;

my $input = $ARGV[0];
my $input2 = $ARGV[1];
my $out = $ARGV[2];
mkdir $out;
my @file;
my $counter_pretty = 0;

open (IN, "<", $input) or die "cannot open $input: $!";
while (my $line = <IN>){
    chomp $line;
    my $filename = $line;
    print $filename . "\t" . $counter_pretty . "\n";
	$counter_pretty++;
    push @file, $filename;
}

my $new;

foreach $file (@file) { #this loop opens each file and replaces the content you specify as it loops through the array 
  
   $new = $file;
	print "New: $new\n";

    open($qq,"<",$input2) or die "could not file";
    open(OUT, ">","$out"."/". substr($new, 0, ((length($new))-4)) . ".ctl") or die "nope";

    while (<$qq>) {
        $_=~ s/stewart.aa/$new/;
        $_=~ s/mlc/out.$new/;
        $_=~ s/stewart.trees/tree.trees/;
        print OUT $_;   
    }
    close OUT;
}



my $counter = 0;
@fs = <$out/*>;
$dirnamer = 1;
$inp = "$out" . "modded";
mkdir $inp;
for(@fs){
	my $localdirnamer = "$inp/ctl.". "$dirnamer"; 
	mkdir $localdirnamer;
        until ($counter > 60){
                `mv $fs[0] $localdirnamer`;
                $counter++;
                shift @fs;
        }
	$dirnamer++;
        $counter = 0;
}

$counter2 = 0;
@fs2 = @file;
$dirnamer2 = 1;
$inp2 = "input" . "modded";
mkdir $inp2;
for(@fs2){
        my $localdirnamer = "$inp2/nuc.". "$dirnamer2";
        mkdir $localdirnamer;
        until ($counter2 > 60){
                `cp $fs2[0] $localdirnamer`;
                $counter2++;
                shift @fs2;
        }
	$dirnamer2++;
        $counter2 = 0;
}


   
   
@list = <$inp2/nuc*>;
@secondlist = <$inp/ctl*>;
$Nest = "Nested";
mkdir $Nest;
$counterv = 1;
foreach $l (@list){
        $dir = "$Nest/" . "$counterv";
        mkdir $dir;
        `mv $l $dir`;
        `mv $secondlist[0] $dir`;
	`cp Paml_executor_complete_final.pl $dir`;
	`cp tree.trees $dir`;
	`cp dat.tar.gz $dir`;
#	`cp qsubheader.qsub $dir`;
	`cp codeml $dir`;
        shift @secondlist;
        $counterv++;
}

