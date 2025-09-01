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
    $result = $result . "$separator$strings->[$i]";
  }
  return $result;
}


1;
