package pm_md;
use strict;
use warnings;
use constant {
  true => 1,
  false => 0
};


sub table_as_markdown {
  my ($table) = @_;
  $table->map(sub {
    my ($record) = @_;

    "$_[0]"
  });
}


1;

