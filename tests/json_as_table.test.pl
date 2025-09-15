use strict;
use warnings;
use lib 'pm_lib';
use pm_include_test;


my $json_text;
my $json;
my $table;
$json_text = '[{"a": 0}, {"a": 1}]';
$json = pm_json::parse($json_text);
$table = pm_json::json_as_table($json);
pm_test_util::assert_equals(["a"], $table->columns_get(), "Columns");
pm_test_util::assert_equals(0, $table->cell(0, 0), "table[0, 0]");
pm_test_util::assert_equals(1, $table->cell(0, 1), "table[0, 1]");

pm_log::separator();

$json_text = <<EOF;
[
  {"a": 0, "b": 1},
  {"a": 2, "b": 3},
  {"a": 4, "b": 5}
]
EOF
$json = pm_json::parse($json_text);
$table = pm_json::json_as_table($json);
pm_test_util::assert_equals(2, $table->columns_get()->size(), "Columns size");
pm_test_util::assert_true($table->columns_get()->contains("a"), "a");
pm_test_util::assert_true($table->columns_get()->contains("b"), "b");
pm_test_util::assert_equals(0, $table->get(0)->get("a"), "table[0]{a}");
pm_test_util::assert_equals(1, $table->get(0)->get("b"), "table[0]{b}");
pm_test_util::assert_equals(2, $table->get(1)->get("a"), "table[1]{a}");
pm_test_util::assert_equals(3, $table->get(1)->get("b"), "table[1]{b}");
pm_test_util::assert_equals(4, $table->get(2)->get("a"), "table[2]{a}");
pm_test_util::assert_equals(5, $table->get(2)->get("b"), "table[2]{b}");
