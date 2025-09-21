use strict;
use warnings;
use lib 'pm_lib';
use pm_include_test;


# Test update failure case


my $db_folder = "$pm_test_util::TEST_DIRECTORY/db_table_update_failure.test";
my $db = pm_db->new($db_folder);
$db->allocate();
pm_test_util::assert_true(-d $db_folder, "Failed to create db");
my $table1 = $db->create_table("table1", ["x", "y"]);
pm_test_util::assert_true(-d "$db_folder/table1", "Failed to create table1");
pm_test_util::assert_die(
  sub { $table1->update({x => 0, y => 0})},
  "Update did not fail"
);
$db->delete();
pm_test_util::assert_false(-d $db_folder, "Failed to delete db");



