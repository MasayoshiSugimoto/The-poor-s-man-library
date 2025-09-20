use strict;
use warnings;
use lib 'pm_lib';
use pm_include_test;


# Test upsert success case


my $db_folder = "$pm_test_util::TEST_DIRECTORY/db_table_upsert.test";
my $db = pm_db->new($db_folder);
$db->allocate();
pm_test_util::assert_true(-d $db_folder, "Failed to create db");
my $table1 = $db->create_table("table1");
pm_test_util::assert_true(-d "$db_folder/table1", "Failed to create table1");
for my $i (1..4) {
  $table1->upsert({
    x => 0,
    y => 0
  });
}
my $v0 = $table1->first();
$v0->{x} = 1;
$v0->{y} = 2;
$table1->upsert($v0);
my $v1;
$v1 = $table1
  ->where(sub {$_[0]->{x} > 0})
  ->first();
pm_test_util::assert_equals(1, $v1->{x}, "x is incorrect");
pm_test_util::assert_equals(2, $v1->{y}, "y is incorrect");
$v1 = $db
  ->from("table1")
  ->where(sub {$_[0]->{x} > 0})
  ->first();
pm_test_util::assert_equals(1, $v1->{x}, "x is incorrect");
pm_test_util::assert_equals(2, $v1->{y}, "y is incorrect");
$db->delete();
pm_test_util::assert_false(-d $db_folder, "Failed to delete db");



