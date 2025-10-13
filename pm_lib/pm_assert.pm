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
  my ($expected, $actual, $text) = @_;
  if (!pm_misc::equals($expected, $actual)) {
    die pm_log::exception("Values are different. $text: expected=$expected, actual=$actual");
  }
}


sub assert_true {
  my ($condition, $text) = @_;
  if (!$condition) {
    if (!defined $text) {
      $text = "Condition is false";
    }
    die pm_log::exception("$text");
  }
}


sub assert_fail {
  my ($text) = @_;
  die pm_log::exception("$text");
}


1;
