package pm_math;

use strict;
use warnings;
use pm_bool qw(true false);


sub min($$) {
  my ($a, $b) = @_;
  return $a < $b ? $a : $b;
}


sub max($$) {
  my ($a, $b) = @_;
  return $a > $b ? $a : $b;
}


1;
