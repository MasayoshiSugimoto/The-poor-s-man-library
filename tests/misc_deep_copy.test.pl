use strict;
use warnings;
use lib 'pm_lib';
use pm_include_test;


my $input;
$input = undef;
pm_test_util::assert_equals(undef, pm_misc::deep_copy($input), "undef");
$input = "hello";
pm_test_util::assert_equals("hello", pm_misc::deep_copy($input), "string");
$input = [1, 2, 3];
pm_test_util::assert_equals([1, 2, 3], pm_misc::deep_copy($input), "array");
$input = {
  a => 1,
  b => "hello",
  c => [1, 2, 3],
  d => {
    x => 4,
    y => 5
  }
};
pm_test_util::assert_equals($input, pm_misc::deep_copy($input), "hash");
