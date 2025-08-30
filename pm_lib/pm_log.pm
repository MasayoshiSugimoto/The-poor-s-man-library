package pm_log;
use strict;
use warnings;


sub debug {
  my ($text) = @_;
  if ($pm_constants::LOG_DEBUG_ENABLE) {
    print STDERR "${pm_color::GREY}DEBUG|$text${pm_color::RESET}\n";
  }
}


sub info {
  my ($text) = @_;
  print STDERR "INFO|$text\n";
}


sub warning {
  my ($text) = @_;
  print STDERR "${pm_color::YELLOW}WARN|$text${pm_color::RESET}\n";
}


sub error {
  my ($text) = @_;
  print STDERR "${pm_color::RED}ERROR|$text${pm_color::RESET}\n";
}


sub separator {
  print "################################################################################\n"
}


1;
