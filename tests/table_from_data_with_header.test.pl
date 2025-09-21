use strict;
use warnings;
use lib 'pm_lib';
use pm_include_test;


my $data = [
  ["X", "Y", "Z"],
  [1  , 2  , 3  ],
  [4  , 5  , 6  ],
  [7  , 8  , 9  ],
];
my $table = pm_table::from_data_with_header($data);
pm_test_util::assert_equals(3, $table->size(), "Table is not of the correct size.");
pm_test_util::assert_equals({X => 1, Y => 2, Z => 3}, $table->row_get(0), "Record 0 does not match");
pm_test_util::assert_equals({X => 4, Y => 5, Z => 6}, $table->row_get(1), "Record 1 does not match");
pm_test_util::assert_equals({X => 7, Y => 8, Z => 9}, $table->row_get(2), "Record 2 does not match");
