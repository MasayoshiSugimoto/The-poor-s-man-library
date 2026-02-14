package pm_arguments;
use strict;
use warnings;
use constant {
  true => 1,
  false => 0
};


my @_positional_arguments = ();
my %_options = ();
my %_flags = ();
# Use an id to map flag definitions to give multiple short and long name.
# For example: `-v` `--verbose`
#
# Sample flag definition
# (
#   "-v" => "VERBOSE",
#   "--verbose" => "VERBOSE"
# )
my %_flag_definitions = ();
# Use an id to map option definition to give multiple short and long name.
# For example: `-v` `--verbose`
#
# Sample option defnition
# (
#   "-s" => "SEPARATOR",
#   "--separator" => "SEPARATOR"
# )
my %_option_definitions = ();


sub parse {
  pm_log::debug("Parsing command line arguments");
  my $option;
  foreach my $arg (@_) {
    if (defined $option) {
      pm_log::debug("Setting option: $option=$arg");
      $_options{$option} = $arg;
      undef $option;
    } elsif (exists $_flag_definitions{$arg}) {
      pm_log::debug("Setting flag $_flag_definitions{$arg}");
      $_flags{$_flag_definitions{$arg}} = true;
    } elsif (exists $_option_definitions{$arg}) {
      pm_log::debug("Setting option id: $_option_definitions{$arg}");
      $option = $_option_definitions{$arg}
    } else {
      pm_log::debug("Setting positional argument: $arg");
      push(@_positional_arguments, $arg);
    }
  }
  !defined $option or die pm_log::exception("Option not defined: $option");
}


sub option_definition_set {
  my ($option_string, $option_id) = @_;
  pm_log::debug("Setting option definition: $option_string:$option_id");
  $_option_definitions{$option_string} = $option_id;
}


sub flag_definition_set {
  my ($flag_string, $flag_id) = @_;
  pm_log::debug("Setting flag definition: $flag_string:$flag_id");
  $_flag_definitions{$flag_string} = $flag_id;
}


sub option_get {
  my ($option_id) = @_;
  return $_options{$option_id};
}


sub flag_get {
  my ($flag_id) = @_;
  if (!exists $_flags{$flag_id}) {
    return false;
  }
  return $_flags{$flag_id};
}


sub positional_argument_get {
  my ($index) = @_;
  return $_positional_arguments[$index];
}


sub positional_argument_size {
  return scalar @_positional_arguments;
}


sub cli_command_mapping_set {
  my ($cli_argument_mapping) = @_;
  my $index = 0;
  my $current_step = $cli_argument_mapping;
  while ($index < positional_argument_size()) {
    my $argument = positional_argument_get($index++);
    pm_log::debug("argument=$argument");
    my $default_handler = $current_step->{$argument};
    my $tmp = ref($current_step);
    if (defined $current_step && ref($current_step) ne "HASH") {
      $current_step->($index);
      return {error => false};
    } elsif (!defined $current_step && ref($default_handler) eq "CODE") {
      $default_handler->();
      return {error => false};
    } elsif (!defined $current_step && pm_string::is_string($default_handler)) {
      return {error => true, message => $default_handler};
    } elsif (!defined $current_step) {
      return {error => true, message => "Invalid command line argument: $argument"};
    }
  }
  return {error => true, message => "No handler matching."};
}


sub clear {
  pm_log::info("Clearing command line arguments");
  @_positional_arguments = ();
  %_options = ();
  %_flags = ();
  %_flag_definitions = ();
  %_option_definitions = ();
}


1;
