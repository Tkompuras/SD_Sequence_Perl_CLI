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

# Subroutine: Opening the fasta file
my $boolean_file_opening = 1;
sub file_opening {
  while($boolean_file_opening) {

    if(-e $input_file) {
      open(FASTA,'<',$input_file) || die color("red"), "Can't open the file", color("reset");
      print color("bold green"), "\nFile opened successfully.\n", color("reset");

      my $desc_line = <FASTA>;
      print color("cyan"), "Description line : \n", color("reset");
      print $desc_line."\n";

      $boolean_file_opening = 0;
    } else {
      print color("red"), "This file does not exist\n", color("reset");
    }
  }
}

# Subroutine: Making the matches and counting them
my $count = 0;
my @matches;
my $file_contents = '';
sub matching {

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

}

# Subroutine: Calculating the reverse complement matches
my @reverse_complement;
sub reverse_matches {
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

}

# Subroutine: File output
sub file_output {
	my $output_file = $input_file.'-output.txt';
	open(OUTPUT, '>', $output_file) or die $!;
	for (my $i=0; $i<@matches; $i++) {
		print OUTPUT "$matches[$i]\n#\n$reverse_complement[$i]\n";
		print OUTPUT "------------------------------------------------------------------------------\n";
	}
}

# Subroutine: Basic file closing
sub file_closing {
  
  close(FASTA) || die color("red"), "close failed: $!", color("reset");
  print color("bold green"), "\nFile closed successfully.\n", color("reset");
  print color("bold blue"), "\nOutput file has been generated - $input_file-output.txt\n", color("reset");

}



# Subroutine: MAIN
file_opening();
matching();
reverse_matches();
file_output();
file_closing();