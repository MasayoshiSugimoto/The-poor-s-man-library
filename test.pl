#!/usr/bin/perl

use strict;
use warnings;
use lib '.';
use lib 'pm_lib';
use Data::Dumper;
use pm_include_test;


my $test_dir_path = "tests";
opendir(my $test_dir, $test_dir_path) or die "Cannot open $test_dir_path $!";
my @files = grep { -f "$test_dir_path/$_" } readdir($test_dir);
foreach my $file (@files) {
  pm_log::info("Executing test: $file");
  my $success = system("perl $test_dir_path/$file");
  if ($success == 0) {
    pm_test_util::succeed("TEST=$file");
  } else {
    pm_test_util::fail("TEST=$file");
  }
}


#my $db = pm_db->new("/tmp/test_db");
#$db->allocate();
#$db->create_table("table1");
#$db->create_table("table2");
#my $table = $db->create_table("my_table");
#$table->set_columns({
#  first_name => {primary_key => true},
#  last_name => {},
#  email => {}
#});
#
#
#for my $i (1..10) {
#  $table->insert({
#    "id" => $i,
#    "value" => "record - $i"
#  });
#}
#
#my $record = $table
#  ->where(sub {$_[0]->{id} == "9"})
#  ->first();
#pm_log::info("id=$record->{id}");
#pm_log::info("value=$record->{value}");
#$record->{"value"} = "new value";
#$table->insert($record);
#pm_log::info("id=$record->{id}");
#pm_log::info("value=$record->{value}");


#$table->drop();
# $db->delete();
