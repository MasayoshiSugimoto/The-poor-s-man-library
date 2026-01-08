package pm_function;


# Call the function and return the value or return default in case of failure.
sub call_or_default {
  my ($function, $default) = @_;
  local $@;
  my $result = eval{$function->();};
  if ($@) {
    return $default;
  }
  return $result;
}


1;
