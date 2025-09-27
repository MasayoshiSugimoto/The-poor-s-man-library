use strict;
use warnings;
use lib 'pm_lib';
use pm_include_test;


my $layout;

$layout = <<EOF;
A--------B------------------C
| menu   | title            |
|        D..................E
|        | content          |
|        |                  |
F--------G------------------H
EOF


pm_ui::layout_parse($layout);


#pm_test_util::assert_equals(4, $table->size(), "Incorrect number of records");
#pm_test_util::assert_equals({c1 => 4, c2 => 5, c3 => 6}, $table->row_get(1), "Pushing array is not correct");
#pm_test_util::assert_equals({c1 => 7, c2 => 8, c3 => 9}, $table->row_get(2), "Pushing list is not correct");
#pm_test_util::assert_equals({c1 => 10, c2 => 11, c3 => 12}, $table->row_get(3), "Pushing hash is not correct");

