package pm_log;
use strict;
use warnings;


sub debug {
  my ($text) = @_;
  if ($pm_constants::LOG_DEBUG_ENABLE) {
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
