package pm_log;
use strict;
use warnings;


my $LOG_OUTPUT;


sub init {
  return if (!defined $pm_constants::LOG_FILE);
  open $LOG_OUTPUT, '>>', $pm_constants::LOG_FILE or die "Failed to open log file.";
  pm_log::info("Logging redirected to file: $pm_constants::LOG_FILE");
  # No need to close as we will use it for the lifetime of the app.
}


sub debug {
  my ($text) = @_;
  if ($pm_constants::LOG_DEBUG_ENABLE) {
    $text = "" if (!defined $text);
   _print("${pm_color::GREY}DEBUG|$text${pm_color::RESET}\n");
  }
}


sub info {
  my ($text) = @_;
  $text = "" if (!defined $text);
  _print("INFO|$text\n");
}


sub warning {
  my ($text) = @_;
  $text = "" if (!defined $text);
  _print("${pm_color::YELLOW}WARN|$text${pm_color::RESET}\n");
}


sub error {
  my ($text) = @_;
  $text = "" if (!defined $text);
  _print("${pm_color::RED}ERROR|$text${pm_color::RESET}\n");
}


sub fatal {
  my ($text) = @_;
  $text = "" if (!defined $text);
  _print("${pm_color::RED}FATAL|$text${pm_color::RESET}\n");
  exit 1;
}


sub exception {
  my ($text) = @_;
  $text = "" if (!defined $text);
  return "${pm_color::RED}ERROR|$text${pm_color::RESET}\n";
}


sub separator {
  _print("################################################################################\n");
}


sub cmd_redirection {
  return defined $LOG_OUTPUT ? "2>> $LOG_OUTPUT" : "";
}


sub _print {
  my ($text) = @_;
  if (!defined $LOG_OUTPUT) {
    print STDERR $text;
  } else {
    print $LOG_OUTPUT $text;
  }
}


1;
