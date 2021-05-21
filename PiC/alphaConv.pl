#!usr/bin/perl

use strict;
#use warnings;

my $input = $ARGV[0];
open (IN,"$input") or die ("ERROR input file: $input\n");
open (OUT,">indcode_alpha") or die ("ERROR output file generation\n");

my @a = ("A".."Z");
my @b = ("a".."Z");

while (my $line =<IN>) {
  chomp $line;
  if ($line =~ m/\[/) {
  my @split = split(/[\[\]\t-]/,$line);
  print OUT "$split[0]\t\[$a[$split[2]-1]$split[3]$b[$split[4]-1]$split[5]\]\n";   
	}
	else{
  my @split = split(/[\t-]/,$line);
  print OUT "$split[0]\t$a[$split[1]-1]$split[2]$b[$split[3]-1]$split[4]\n";
 }
}
close IN;
close OUT;

system("sed -i 's/z//g' indcode_alpha");
system("sed -i 's/Z//g' indcode_alpha");

exit;
