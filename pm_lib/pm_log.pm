package pm_log;


sub debug {
  my ($text) = @_;
  if ($pm_db_constants::LOG_DEBUG_ENABLED) {
    print STDERR "DEBUG|$text\n";
  }
}


sub info {
  my ($text) = @_;
  print STDERR "INFO|$text\n";
}


sub warning {
  my ($text) = @_;
  print STDERR "WARN|$text";
}


sub error {
  my ($text) = @_;
  print STDERR "ERROR|$text";
}


1;
