package pm_test_util;

use strict;
use warnings;
use Scalar::Util qw(looks_like_number);


our $TEST_DIRECTORY = '/tmp/pm_test';
if (!-d $TEST_DIRECTORY) {
  mkdir $TEST_DIRECTORY;
}


sub assert_equals {
  my ($expected, $actual, $text) = @_;
  if (!defined $text) {
    $text = "Unexpected value";
  }
  if (!ref($expected) && !ref($actual)) {
    if (looks_like_number($expected) && looks_like_number($actual)) {
      if ($expected != $actual) {
        fail("$text: expected:$expected actual:$actual");
      }
    } elsif (!looks_like_number($expected) && !looks_like_number($actual)) {
      if ($expected ne $actual) {
        fail("$text: expected:$expected actual:$actual");
      }
    } else {
      fail("$text: expected:$expected actual:$actual");
    }
  } else {
    fail("Unsupported");
  }
}


sub assert_true {
  my ($condition, $text) = @_;
  if (!$condition) {
    if (!defined $text) {
      fail("Condition failed");
    } else {
      fail($text);
    }
  }
}


sub assert_false {
  my ($condition, $text) = @_;
  assert_true(!$condition, $text);
}


sub assert_die {
  my ($f, $text) = @_;
  eval {
    $f->();
  };
  if ($@) {
    pm_log::debug("Exception occured: $@");
  } else {
    die "Expecting failure but did not happened: $text";
  }
}


sub succeed {
  my ($text) = @_;
  print STDERR "${pm_color::GREEN}SUCCESS${pm_color::RESET}|$text\n";
}


sub fail {
  my ($text) = @_;
  print STDERR "${pm_color::RED}FAILURE${pm_color::RESET}|$text\n";
  exit 1;
}


1;
