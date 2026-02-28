package pm_bool;

use strict;
use warnings;
use Exporter 'import';


our @EXPORT_OK = qw(
  true
  false
);


use constant {
  true => 1,
  false => 0
};


1;
