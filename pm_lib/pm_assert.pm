package pm_assert;
use strict;
use warnings;


sub assert_defined {
  my ($value, $text) = @_;
  if (!defined $value && defined $text) {
    die pm_log::exception("Undefined variable: $text");
  } elsif (!defined $value) {
    die pm_log::exception("Undefined variable");
  }
}


sub assert_equals {
  my ($a, $b, $text) = @_;
  if (!pm_misc::equals($a, $b)) {
    die pm_log::exception("Values are different: $text. a=$a, b=$b");
  }
}


sub assert_true {
  my ($condition, $text) = @_;
  $condition or die pm_log::exception("");
}


1;
