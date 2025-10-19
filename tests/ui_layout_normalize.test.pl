use strict;
use warnings;
use lib 'pm_lib';
use pm_include_test;


$pm_constants::CONSOLE_SIZE_DEBUG = {x => 21, y => 10};
my $layout_as_text;
my $constraints;

$layout_as_text = <<EOF;
A--------B------------------C
| menu   | title            |
|        D..................E
|        | content          |
|        |                  |
F--------G------------------H
EOF
$constraints = pm_layout::from_string($layout_as_text)
  ->_constraint_normalize({
    size => {
      width => "100%",  # 100% of the terminal size
      height => "100%"
    },
    ABGF => {
      width => "50%"
    },
    BCED => {
      horizontal_alignment => "center",
      vertical_alignment => "center",
      height =>  3  # Number of rows (Without borders)
    }
  });
pm_test_util::assert_equals({}, $constraints, "Simple example");


