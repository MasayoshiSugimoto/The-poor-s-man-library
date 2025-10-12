package pm_constants;
use strict;
use warnings;
use constant {
  true => 1,
  false => 0
};


our $LOG_DEBUG_ENABLE = true;

our $DB_TABLE_PRIMARY_KEY_FIELD = "_primary_key";

our $CONSOLE_SIZE_DEBUG = undef;
# Uncomment if you want to test rendering
#our $CONSOLE_SIZE_DEBUG = {x => 10, y => 5};


1;
