package pm_include_test;


use strict;
use warnings;
use pm_include;
use pm_test_util;
use Exporter 'import';
our @EXPORT = qw(true false);


use constant {
  true => 1,
  false => 0
};

1;

