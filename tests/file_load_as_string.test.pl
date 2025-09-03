use strict;
use warnings;
use lib 'pm_lib';
use pm_include_test;


my $file_path = "$pm_test_util::TEST_DIRECTORY/test_file";
pm_file::file_safe_delete($file_path);
my $content_in = <<EOF;
line1
line1

line3
EOF
pm_file::file_save_string($file_path, $content_in);
my $content_out = pm_file::file_load_as_string($file_path);
pm_test_util::assert_equals($content_in, $content_out, "Content saved and loaded are different");
