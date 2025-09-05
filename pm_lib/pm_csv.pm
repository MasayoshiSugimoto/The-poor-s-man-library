package pm_csv;
use strict;
use warnings;


sub pm_csv::from_string {
  my ($string, $separator) = @_;
  my $lines = pm_string::split_by_line($string);
  my $csv = $lines->map(sub {pm_string::split(/[^\\]$separator/, $_[0])});
}


1;

