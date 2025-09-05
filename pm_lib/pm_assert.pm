package pm_assert;
use strict;
use warnings;


sub assert_defined {
  my ($value) = @_;
  defined $value || die "";
}


sub assert_equals {
  my ($a, $b, $text) = @_;
  if (!pm_misc::equals($a, $b)) {
    die "Values are different: $text";
  }
}


1;
