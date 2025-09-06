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
  pm_log::debug("Setting option definition");
  my ($option_string, $option_id) = @_;
  $_option_definitions{$option_string} = $option_id;
}


sub flag_definition_set {
  pm_log::debug("Setting flag definition");
  my ($flag_string, $flag_id) = @_;
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


sub clear {
  pm_log::info("Clearing command line arguments");
  @_positional_arguments = ();
  %_options = ();
  %_flags = ();
  %_flag_definitions = ();
  %_option_definitions = ();
}


1;
