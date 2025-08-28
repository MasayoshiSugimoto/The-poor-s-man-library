use strict;
use warnings;
use lib 'pm_lib';
use pm_include_test;


# Create a table, drop it and confirm that the directory has been deleted.


my $db_folder = "$pm_test_util::TEST_DIRECTORY/db_table_drop.test";
my $db = pm_db->new($db_folder);
$db->allocate();
pm_test_util::assert_true(-d $db_folder, "Failed to create db");
my $table1 = $db->create_table("table1");
pm_test_util::assert_true(-d "$db_folder/table1", "Failed to create table1");
my $table2 = $db->create_table("table2");
pm_test_util::assert_true(-d "$db_folder/table2", "Failed to create table2");
$table1->drop();
pm_test_util::assert_false(-d "$db_folder/table1", "Failed to drop table1");
$table2->drop();
pm_test_util::assert_false(-d "$db_folder/table2", "Failed to drop table2");
$db->delete();
pm_test_util::assert_false(-d $db_folder, "Failed to delete db");
