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
  my @groups = split($regex, $string, -1);
  return pm_list->new(\@groups);
}


sub as_safe_string {
  my ($string) = @_;
  if (!defined $string) {
    return "";
  }
  return $string;
}


sub split_by_line {
  my ($string) = @_;
  my @lines = split(/\n/, $string, -1);
  return pm_list->new(\@lines)
    ->map(\&as_safe_string);
}


sub is_empty {
  my ($string) = @_;
  return as_safe_string($string) eq "";
}


sub left_pad {
  my ($string, $target_length, $character) = @_;
  $character = " " if (!defined $character);
  my $string_length = length($string);
  my $padding_length = $target_length - $string_length;
  my $padding = $character x ($padding_length);
  return "$padding$string";
}


sub right_pad {
  my ($string, $target_length, $character) = @_;
  $character = " " if (!defined $character);
  my $string_length = length($string);
  my $padding_length = $target_length - $string_length;
  my $padding = $character x ($padding_length);
  return "$string$padding";
}


sub trim {
  my ($string) = @_;
  $string =~ s/^\s+//;
  $string =~ s/\s+$//;
  return $string;
}


sub as_linux_string {
  my ($string) = @_;
  $string =~ s/\r//g;
  return $string;
}


sub is_string {
  my ($var) = @_;
  return defined $var && !ref($var);
}


1;
