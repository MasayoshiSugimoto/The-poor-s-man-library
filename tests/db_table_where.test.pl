use strict;
use warnings;
use lib 'pm_lib';
use pm_include_test;


# Create few records and filter them.


my $db_folder = "$pm_test_util::TEST_DIRECTORY/db_table_where.test";
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
my $v = $table1->where(sub {$_[0]->{x} == 3})
  ->first();
pm_test_util::assert_equals(3, $v->{x}, "x is incorrect");
pm_test_util::assert_equals(30, $v->{y}, "y is incorrect");
$db->delete();
pm_test_util::assert_false(-d $db_folder, "Failed to delete db");

