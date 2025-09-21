use strict;
use warnings;
use lib 'pm_lib';
use pm_include_test;


# Test record deletion


my $db_folder = "$pm_test_util::TEST_DIRECTORY/db_table_delete.test";
my $db = pm_db->new($db_folder);
$db->allocate();
pm_test_util::assert_true(-d $db_folder, "Failed to create db");
my $table1 = $db->create_table("table1", ["x", "y"]);
pm_test_util::assert_true(-d "$db_folder/table1", "Failed to create table1");
for my $i (1..10) {
  $table1->insert({
    x => pm_gen::int_generate(),
    y => pm_gen::int_generate()
  });
}
my $all = [];
$all = $db->from("table1")->as_table();
pm_test_util::assert_equals(10, $all->size(), "Number of records is not correct");
my $v = $table1
  ->where(sub {$_[0]->get("$pm_constants::DB_TABLE_PRIMARY_KEY_FIELD") == 2})
  ->first();
$table1->delete($v);
$all = $table1->as_table();
pm_test_util::assert_equals(9, $all->size(), "Record not deleted in memory");
$all = $db->from("table1")->as_table();
pm_test_util::assert_equals(9, $all->size(), "Record not deleted on disk");
$db->delete();
pm_test_util::assert_false(-d $db_folder, "Failed to delete db");



