package pm_csv;
use strict;
use warnings;
use constant {
  true => 1,
  false => 0
};


our $HEADER_ON = true;
our $HEADER_OFF = false;


sub pm_csv::from_string {
  my ($string, $has_header, $separator) = @_;
  if (!defined $separator) {
    $separator = ",";
  }
  my @lines = split(/\n/, $string, -1);
  pm_assert::assert_true(scalar @lines > 0, "Empty csv");
  my @header = ();
  my $start = 0;
  if ($has_header) {
    @header = split(/$separator/, $lines[0], -1);
    $start = 1;
  } else {
    my @l = split(/$separator/, $lines[0], -1);
    for (my $i = 0; $i < scalar @l; $i++) {
      push(@header, "c$i");
    }
  }
  my @result;
  for (my $i = $start; $i < scalar @lines; $i++) {
    last if (pm_string::is_empty($lines[$i]));
    my @l = split(/$separator/, $lines[$i], -1);
    push(@result, \@l);
  }
  return pm_table->new(\@header, \@result);
}


1;

