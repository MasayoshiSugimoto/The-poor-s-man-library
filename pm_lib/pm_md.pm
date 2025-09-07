package pm_md;
use strict;
use warnings;
use constant {
  true => 1,
  false => 0
};


sub table_as_markdown {
  my ($table) = @_;

  my $columns = $table->columns_get();
  my $width = $columns->size();
  my $height = $table->size();

  # Calculate the width of each columns
  my @column_widths = @{
    $columns
      ->map(sub {length($_[0])})
      ->as_array()
  };
  for (my $y = 0; $y < $height; $y++) {
    for (my $x = 0; $x < $width; $x++) {
      my $cell = $table->cell($x, $y);
      if (length($cell) > $column_widths[$x]) {
        $column_widths[$x] = length($cell);
      }
    }
  }

  # Generate header
  my $result = "|";
  for (my $x = 0; $x < $width; $x++) {
    my $field = $columns->get($x);
    $result .= pm_string::right_pad(" $field ", $column_widths[$x] + 2);
    $result .= "|";
  }
  $result .= "\n|";
  for (my $x = 0; $x < $width; $x++) {
    my $field = $columns->get($x);
    $result .= pm_string::right_pad("", $column_widths[$x] + 2, "-");
    $result .= "|";
  }

  # Generate table
  for (my $y = 0; $y < $height; $y++) {
    $result .= "\n|";
    for (my $x = 0; $x < $width; $x++) {
      my $cell = $table->cell($x, $y);
      $result .= pm_string::right_pad(" $cell ", $column_widths[$x] + 2);
      $result .= "|";
    }
  }
  $result .= "\n";

  return $result;
}


1;

