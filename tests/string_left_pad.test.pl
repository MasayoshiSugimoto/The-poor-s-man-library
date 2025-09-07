use strict;
use warnings;
use lib 'pm_lib';
use pm_include_test;


pm_test_util::assert_equals("hello", pm_string::left_pad("hello", 0), "'hello'");
pm_test_util::assert_equals("hello", pm_string::left_pad("hello", 4), "'hello'");
pm_test_util::assert_equals("hello", pm_string::left_pad("hello", 5), "'hello'");
pm_test_util::assert_equals("   hello", pm_string::left_pad("hello", 8), "'   hello'");
pm_log::separator();
pm_test_util::assert_equals("hello", pm_string::left_pad("hello", 0, "*"), "'hello'");
pm_test_util::assert_equals("hello", pm_string::left_pad("hello", 4, "*"), "'hello'");
pm_test_util::assert_equals("hello", pm_string::left_pad("hello", 5, "*"), "'hello'");
pm_test_util::assert_equals("***hello", pm_string::left_pad("hello", 8, "*"), "'***hello'");
