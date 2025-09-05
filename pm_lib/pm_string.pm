package pm_string;


sub without_new_line {
  my ($string) = @_;
  $string =~ s/\r?\n$//;
  return $string;
}


sub join {
  my ($strings, $separator) = @_;
  if (!defined $separator) {
    $separator = "";
  }
  my $size = @$strings;
  if ($size == 0) {
    return "";
  }
  my $result = $strings->[0];
  for (my $i = 1; $i < $size; $i++) {
    $result .= "$separator$strings->[$i]";
  }
  return $result;
}


sub split {
  my ($regex, $string) = @_;
  my @groups = split($regex, $string);
  return pm_list->new(\@groups);
}


sub split_by_line {
  my ($string) = @_;
  my @lines = split(/[^\\]\n/, $string);
  return pm_list->new(\@lines);
}


1;
