use strict;
use warnings;
use lib 'pm_lib';
use pm_include_test;


# Create a db then delete it.

my $db_folder = "$pm_test_util::TEST_DIRECTORY/db_create.test";
my $db = pm_db->new($db_folder);
$db->allocate();
pm_test_util::assert_true(-d $db_folder, "Failed to create db");
$db->delete();
pm_test_util::assert_false(-d $db_folder, "Failed to delete db");
