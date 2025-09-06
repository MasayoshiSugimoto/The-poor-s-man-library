use strict;
use warnings;
use lib 'pm_lib';
use pm_include_test;

my $text;
my $lines;
$text = <<EOF;

line1
line2\\n
line3\\nsame line\\n
EOF
pm_log::debug("text=$text");
$lines = pm_string::split_by_line($text);
pm_assert::assert_equals(5, $lines->size(), "Incorrect number of lines");
pm_assert::assert_equals("", $lines->get(0), "line0");
pm_assert::assert_equals("line1", $lines->get(1), "line1");
pm_assert::assert_equals("line2\\n", $lines->get(2), "line2");
pm_assert::assert_equals("line3\\nsame line\\n", $lines->get(3), "line3");
pm_assert::assert_equals("", $lines->get(4), "line4");

pm_log::separator();

$text = "line1";
pm_log::debug("text=$text");
$lines = pm_string::split_by_line($text);
pm_assert::assert_equals(1, $lines->size(), "Incorrect number of lines");
pm_assert::assert_equals("line1", $lines->get(0), "line1");
