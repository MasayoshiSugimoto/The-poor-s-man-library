use strict;
use warnings;
use lib 'pm_lib';
use pm_include_test;


# Parse a complex example of command line arguments

pm_log::debug("---");
pm_arguments::flag_definition_set("-v", "VERBOSE");
pm_arguments::flag_definition_set("--verbose", "VERBOSE");
pm_arguments::flag_definition_set("-i", "IGNORE_CASE");
pm_arguments::flag_definition_set("--ignore-case", "IGNORE_CASE");
pm_arguments::option_definition_set("-m", "MAX_COUNT");
pm_arguments::option_definition_set("--max-count", "MAX_COUNT");
pm_arguments::option_definition_set("-n", "LINE_NUMBER");
pm_arguments::option_definition_set("--line-number", "LINE_NUMBER");
pm_arguments::parse("-i", "-m", "1", "-v", "-n", "2", "pattern", "file");
pm_test_util::assert_true(pm_arguments::flag_get("VERBOSE"));
pm_test_util::assert_true(pm_arguments::flag_get("IGNORE_CASE"));
pm_test_util::assert_equals("1", pm_arguments::option_get("MAX_COUNT"));
pm_test_util::assert_equals("2", pm_arguments::option_get("LINE_NUMBER"));
pm_test_util::assert_equals(2, pm_arguments::positional_argument_size());
pm_test_util::assert_equals("pattern", pm_arguments::positional_argument_get(0));
pm_test_util::assert_equals("file", pm_arguments::positional_argument_get(1));
pm_log::debug("---");
pm_arguments::clear();
pm_arguments::flag_definition_set("-v", "VERBOSE");
pm_arguments::flag_definition_set("--verbose", "VERBOSE");
pm_arguments::flag_definition_set("-i", "IGNORE_CASE");
pm_arguments::flag_definition_set("--ignore-case", "IGNORE_CASE");
pm_arguments::option_definition_set("-m", "MAX_COUNT");
pm_arguments::option_definition_set("--max-count", "MAX_COUNT");
pm_arguments::option_definition_set("-n", "LINE_NUMBER");
pm_arguments::option_definition_set("--line-number", "LINE_NUMBER");
pm_arguments::parse(
  "--ignore-case",
  "--max-count", "1",
  "--verbose",
  "--line-number", "2",
  "pattern",
  "file"
);
pm_test_util::assert_true(pm_arguments::flag_get("VERBOSE"));
pm_test_util::assert_true(pm_arguments::flag_get("IGNORE_CASE"));
pm_test_util::assert_equals("1", pm_arguments::option_get("MAX_COUNT"));
pm_test_util::assert_equals("2", pm_arguments::option_get("LINE_NUMBER"));
pm_test_util::assert_equals(2, pm_arguments::positional_argument_size());
pm_test_util::assert_equals("pattern", pm_arguments::positional_argument_get(0));
pm_test_util::assert_equals("file", pm_arguments::positional_argument_get(1));
pm_log::debug("---");
pm_arguments::clear();
pm_arguments::flag_definition_set("-v", "VERBOSE");
pm_arguments::flag_definition_set("--verbose", "VERBOSE");
pm_arguments::flag_definition_set("-i", "IGNORE_CASE");
pm_arguments::flag_definition_set("--ignore-case", "IGNORE_CASE");
pm_arguments::option_definition_set("-m", "MAX_COUNT");
pm_arguments::option_definition_set("--max-count", "MAX_COUNT");
pm_arguments::option_definition_set("-n", "LINE_NUMBER");
pm_arguments::option_definition_set("--line-number", "LINE_NUMBER");
pm_arguments::parse("-m", "1", "-v", "pattern", "file");
pm_test_util::assert_true(pm_arguments::flag_get("VERBOSE"), "VERBOSE flag incorrect");
pm_test_util::assert_false(pm_arguments::flag_get("IGNORE_CASE"), "IGNORE_CASE flag incorrect");
pm_test_util::assert_equals("1", pm_arguments::option_get("MAX_COUNT"), "MAX_COUNT incorrect");
pm_test_util::assert_undefined(pm_arguments::option_get("LINE_NUMBER"), "LINE_NUMBER incorrect");
pm_test_util::assert_equals(2, pm_arguments::positional_argument_size(), "Positional argument size incorrect");
pm_test_util::assert_equals("pattern", pm_arguments::positional_argument_get(0), "Positional argument 0 incorrect");
pm_test_util::assert_equals("file", pm_arguments::positional_argument_get(1), "Positional argument 1 incorrect");
