use strict;
use warnings;
use lib 'pm_lib';
use pm_include_test;

my $expected;
$expected = <<EOF;
| c1      | c2     | c3      |
|---------|--------|---------|
| Jean    | Dupond | 1234567 |
| Michel  | Durand | 2345678 |
| Giselle | Proust | 3456789 |
EOF
my $table = pm_md::parse_markdown_table($expected);
pm_test_util::assert_equals(["c1", "c2", "c3"], $table->columns_get(), "Invalid header");
pm_test_util::assert_equals(3, $table->size(), "Table size is incorrect");
pm_test_util::assert_equals(
  {c1 => "Jean", c2 => "Dupond", c3 => "1234567"},
  $table->row_get(0)
);
pm_test_util::assert_equals(
  {c1 => "Michel", c2 => "Durand", c3 => "2345678"},
  $table->row_get(1)
);
pm_test_util::assert_equals(
  {c1 => "Giselle", c2 => "Proust", c3 => "3456789"},
  $table->row_get(2)
);


