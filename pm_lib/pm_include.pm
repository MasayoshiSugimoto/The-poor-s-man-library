package pm_include;


use strict;
use warnings;
use Data::Dumper;
use pm_db;
use pm_db_table;
use pm_db_util;
use pm_log;
use pm_string;
use Exporter 'import';
our @EXPORT = qw(true false);


use constant {
  true => 1,
  false => 0
};

1;
