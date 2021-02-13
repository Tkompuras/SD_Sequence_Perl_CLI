#!/usr/bin/env perl
use Getopt::Long 'HelpMessage';
use strict;
use warnings;
use Term::ANSIColor;

GetOptions(
  'input=s' => \my $input_file,
  'help'     =>   sub { HelpMessage(0) },
) or HelpMessage(1);

# die unless we got the mandatory argument
HelpMessage(1) unless $input_file;

=pod

=head1 NAME

shine_dalgarno - An attempt to code a very basic command line interface to find Shine-Dalgarno sequences in whole genome fasta files!

=head1 SYNOPSIS

  --input,-i      Input file (required)
  --help,-h       Print this help

=cut

#------------------------------------------------------------------------------------------------------------------------------------------------

# Opening the fasta file
my $boolean_file_opening = 1;
my $desc_line = '';
while($boolean_file_opening) {

if(-e $input_file) {
  open(FASTA,'<',$input_file) || die color("red"), "Can't open the file", color("reset");
  #print color("bold green"), "\nFile opened successfully.\n", color("reset");

  $desc_line = <FASTA>;
  chomp $desc_line;
  $desc_line =~ s/,/ /;
  print color("cyan"), "Description line : \n", color("reset");
  print $desc_line."\n";

  $boolean_file_opening = 0;
} else {
  die color("red"), "This file does not exist\n", color("reset");
}
}

# Making the matches and counting them
my $count = 0;
my @matches;
my $file_contents = '';

while(my $line = <FASTA>) {
  chomp $line;
  $file_contents = $file_contents.$line;
}

# Matching Pattern
while ($file_contents =~ /([TA][AC]AGGA[GA][GA][ATGC]{4,10}ATG(\w\w\w)*?(TAA|TGA|TAG))/g) {
  push @matches, $1;
  $count += 1;
}

print color("bold cyan"), "\nThere have been $count matches.\n", color("reset");


# Calculating the reverse complement matches
my @reverse_complement;
my @reverse;
my $reverse;

foreach (@matches) {
	$reverse = reverse $_;
	push @reverse, $reverse;
}

foreach (@reverse) {
	$_ =~ tr/ATGC/TACG/;
	push @reverse_complement, $_;
}

# File output
my $output_file = 'output.csv';
open(OUTPUT, '>', $output_file) or die $!;
print OUTPUT "$desc_line\n";
print OUTPUT "Match #,Length,Match Sequence, Reverse-Complement Sequence\n";
for (my $i=0; $i<@matches; $i++) {
	my $length = length($matches[$i]);
	print OUTPUT "${\($i+1)},$length,$matches[$i],$reverse_complement[$i]\n";
}

# Basic file closing
close(FASTA) || die color("red"), "close failed: $!", color("reset");
#print color("bold green"), "\nFile closed successfully.\n", color("reset");
print color("bold blue"), "\nOutput file has been generated - $input_file-output.txt\n", color("reset");
