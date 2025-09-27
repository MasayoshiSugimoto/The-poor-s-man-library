#!/usr/bin/perl

use strict;
use warnings;
use lib '.';
use lib 'pm_lib';
use Data::Dumper;
use pm_include_test;


pm_file::directory_delete($pm_test_util::TEST_DIRECTORY);
my $test_dir_path = "tests";
opendir(my $test_dir, $test_dir_path)
  or die pm_log::exception("Cannot open $test_dir_path $!");
my @files = grep { -f "$test_dir_path/$_" } readdir($test_dir);
# Change the file name to test only one file.
@files = ("ui_parse_layout.test.pl");
foreach my $file (@files) {
  pm_log::info("Executing test: $file");
  my $success = system("perl $test_dir_path/$file");
  if ($success == 0) {
    pm_test_util::succeed("TEST=$file");
  } else {
    pm_test_util::fail("TEST=$file");
  }
  pm_log::separator();
}
