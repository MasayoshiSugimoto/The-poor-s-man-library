use strict;
use warnings;
use lib 'pm_lib';
use pm_include_test;


my $columns = ["c1", "c2", "c3"];
my $data = [
  [1, 2, 3],
  [4, 5, 6],
  [7, 8, 9]
];
my $table = pm_table->new($columns, $data);
my $record = $table->filter(sub {$_[0]->get('c1') > 4})
  ->first();
pm_test_util::assert_equals({c1 => 7, c2 => 8, c3 => 9}, $record, "Record does not match");
