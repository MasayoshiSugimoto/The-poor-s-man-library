use strict;
use warnings;
use lib 'pm_lib';
use pm_include_test;

my $columns = ["First Name", "Last Name", "Tel"];
my $data = [
  ["Jean","Dupond", 1234567],
  ["Michel", "Durand", 2345678],
  ["Giselle", "Proust", 3456789]
];
my $table = pm_table->new($columns, $data);
my $md = pm_md::table_as_markdown($table);
my $expected = <<EOF;
| First Name | Last Name | Tel     |
|------------|-----------|---------|
| Jean       | Dupond    | 1234567 |
| Michel     | Durand    | 2345678 |
| Giselle    | Proust    | 3456789 |
EOF
pm_test_util::assert_equals($expected, $md, "Tables are different");

pm_log::separator();

$data = [
  ["Jean","Dupond", 1234567],
  ["Michel", "Durand", 2345678],
  ["Giselle", "Proust", 3456789]
];
$table = pm_table->new(undef, $data);
$md = pm_md::table_as_markdown($table);
pm_log::debug($md);
$expected = <<EOF;
| A       | B      | C       |
|---------|--------|---------|
| Jean    | Dupond | 1234567 |
| Michel  | Durand | 2345678 |
| Giselle | Proust | 3456789 |
EOF
pm_test_util::assert_equals($expected, $md, "Tables are different");

1;
