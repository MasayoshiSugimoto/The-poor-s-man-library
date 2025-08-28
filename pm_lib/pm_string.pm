package pm_string;


sub without_new_line {
  my ($string) = @_;
  $string =~ s/\r?\n$//;
  return $string;
}


1;
