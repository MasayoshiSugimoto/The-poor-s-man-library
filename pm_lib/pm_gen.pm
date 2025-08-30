
package pm_gen;

use strict;
use warnings;


my $INT_MIN_DEFAULT = -1_000_000;
my $INT_MAX_DEFAULT = 1_000_000;


sub int_generate {
  my ($params) = @_;
  my $min = $INT_MIN_DEFAULT;
  my $max = $INT_MAX_DEFAULT;
  if (exists $params->{min}) {
    $min = $params->{min};
  }
  if (exists $params->{max}) {
    $max = $params->{max};
  }
  my $range = abs($min) + abs($max);
  return int($min + rand($range));
}


1;
