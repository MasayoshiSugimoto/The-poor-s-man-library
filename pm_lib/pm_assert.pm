package pm_assert;
use strict;
use warnings;


sub assert_defined {
  my ($value) = @_;
  defined $value || die "";
}


1;
