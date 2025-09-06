use strict;
use warnings;
use lib 'pm_lib';
use pm_include_test;


pm_test_util::assert_equals(undef, pm_misc::normalize(undef), "undef");
pm_test_util::assert_equals(0, pm_misc::normalize(0), "0");
pm_test_util::assert_equals(1, pm_misc::normalize(1), "1");
pm_test_util::assert_equals("", pm_misc::normalize(""), "");
pm_test_util::assert_equals("x", pm_misc::normalize("x"), "x");
pm_test_util::assert_equals([], pm_misc::normalize([]), "[]");
pm_test_util::assert_equals([1], pm_misc::normalize([1]), "[1]");
pm_test_util::assert_equals([1], pm_misc::normalize(pm_list->new([1])), "[1]");
pm_test_util::assert_equals({}, pm_misc::normalize({}), "{}");
pm_test_util::assert_equals({a=>0}, pm_misc::normalize({a=>0}), "{a=>0}");
