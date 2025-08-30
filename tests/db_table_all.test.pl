use strict;
use warnings;
use lib 'pm_lib';
use pm_include_test;


# Test `all` function


my $db_folder = "$pm_test_util::TEST_DIRECTORY/db_table_all.test";
my $db = pm_db->new($db_folder);
$db->allocate();
pm_test_util::assert_true(-d $db_folder, "Failed to create db");
my $table1 = $db->create_table("table1");
pm_test_util::assert_true(-d "$db_folder/table1", "Failed to create table1");
my $table2 = $db->create_table("table2");
pm_test_util::assert_true(-d "$db_folder/table2", "Failed to create table2");
for my $i (1..4) {
  $table1->insert({
    x => $i,
    y => $i * 10
  });
}
my $result = $table1
  ->where(sub {$_[0]->{x} > 2})
  ->all();
pm_test_util::assert_equals(2, $result->size(), "Incorrect number of elements");
pm_test_util::assert_equals(3, $result->get(0)->{x}, "First element is not correct");
pm_test_util::assert_equals(4, $result->get(1)->{x}, "Second element is not correct");
$db->delete();
pm_test_util::assert_false(-d $db_folder, "Failed to delete db");

