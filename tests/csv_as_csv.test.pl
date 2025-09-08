use strict;
use warnings;
use lib 'pm_lib';
use pm_include_test;


my $columns = ["c1", "c2", "c3", "fruits"];
my $data = [
  [1, 2, 3, "banana"],
  [4, 5, 6, "apple"],
  [7, 8, 9, "lemon"]
];
my $table = pm_table->new($columns, $data);
my $csv = pm_csv::as_csv($table, $pm_csv::HEADER_ON, ",");
my $expected = <<EOF;
c1,c2,c3,fruits
1,2,3,banana
4,5,6,apple
7,8,9,lemon
EOF
$expected =~ s/\n$//;
pm_test_util::assert_equals($expected, $csv, "Invalid CSV: has_header=HEADER_ON, separator=,");

pm_log::separator();

$csv = pm_csv::as_csv($table, $pm_csv::HEADER_OFF, ",");
$expected = <<EOF;
1,2,3,banana
4,5,6,apple
7,8,9,lemon
EOF
$expected =~ s/\n$//;
pm_file::file_save_string("/tmp/actual.csv", $csv);
pm_file::file_save_string("/tmp/expected.csv", $expected);
pm_test_util::assert_equals($expected, $csv, "Invalid CSV: has_header=HEADER_OFF, separator=,");

pm_log::separator();

$csv = pm_csv::as_csv($table, $pm_csv::HEADER_OFF, "	");
$expected = <<EOF;
1	2	3	banana
4	5	6	apple
7	8	9	lemon
EOF
$expected =~ s/\n$//;
pm_file::file_save_string("/tmp/actual.csv", $csv);
pm_file::file_save_string("/tmp/expected.csv", $expected);
pm_test_util::assert_equals($expected, $csv, "Invalid CSV: has_header=HEADER_OFF, separator=	");

