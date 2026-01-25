#!/usr/bin/perl
use strict;
use warnings;
use lib '.';
use lib 'pm_lib';
use Data::Dumper;
use pm_include;
use constant {
  true => 1,
  false => 0
};

package main;
$pm_constants::LOG_DEBUG_ENABLE = false;
my $PATH = 'pokeapi.co/api/v2/pokemon';
my $STATE = pk_list_view->new();


sub http_get {
  my ($url) = @_;
  print('.');
  return pm_http_client->new($url)->get();
}


sub prompt_commands_render {
  my ($commands) = @_;
  print_event("Select command:");
  foreach my $key (sort keys %$commands) {
    my $description = $commands->{$key};
    print("$key: ${description}\n");
  }
}


sub println {
  my ($text) = @_;
  $text = '' if (!defined $text);
  print("$text\n");
}


sub print_event {
  my ($text) = @_;
  print("> $text\n");
}


# We want to start a loop and request input from the user after each steps.
# For each step, we maintain a path in the object.
# We print a header, then the data, then a message with available options.

sub run {
  while (true) {
    $STATE->update();
    main::println();
    main::prompt_commands_render($STATE->command_get());
    print("< ");
    my $line = <STDIN>;
    $STATE->input_handle($line);
  }
}

# Launching app

run();


package pk_list_view;


sub new {
  my ($class) = @_;
  my $self = {
    url => "https://pokeapi.co/api/v2/pokemon",
    page => 0,
    page_size => 10,
    last_result => undef
  };
  bless $self, $class;
  return $self;
}


sub _url_get {
  my ($self) = @_;
  my $offset = $self->_offset_get();
  my $limit = $self->{page_size};
  return "$self->{url}/?offset=$offset&limit=$limit"
}


sub _page_next {
  my ($self) = @_;
  my $count = $self->_count_get();
  my $new_offset = ($self->{page} + 1) * $self->{page_size};
  if ($new_offset >= $count) {
    main::print_event("Already on last page. Cannot go to next page.");
    return;
  }
  $self->{page}++;
  return $self;
}


sub _page_previous {
  my ($self) = @_;
  if ($self->{page} <= 0) {
    main::print_event("Already on page 0. Cannot go to previous page.");
    return;
  }
  $self->{page}--;
}


sub _count_get {
  my ($self) = @_;
  return 0 if (!defined $self->{last_result});
  my $result;
  eval {
    $result = $self->{last_result}->{count};
  };
  if ($@) {
    my $result = pm_misc::as_text($self->{last_result});
    pm_assert::assert_fail("Result does not contain count. result=$result");
  }
  return $result;
}


sub _offset_get {
  my ($self) = @_;
  return $self->{page} * $self->{page_size};
}


sub update {
  my ($self) = @_;
  main::print_event("Querying pokemon list (page:$self->{page}).");
  my $url = $self->_url_get();
  my $result = main::http_get($url);
  #pm_log::info(pm_misc::as_text($result));
  $self->{last_result} = $result;
  my $pokemons = $result->{results};
  my $table = pm_table->new(['Name', 'Type 1', 'Type 2']);
  foreach my $pokemon_ref (@$pokemons) {
    my $pokemon = main::http_get($pokemon_ref->{url});
    $table->push({
      'Name' => pm_function::call_or_default(sub {$pokemon->{name}}, ""),
      'Type 1' => pm_function::call_or_default(sub {$pokemon->{types}->[0]->{type}->{name}}, ""),
      'Type 2' => pm_function::call_or_default(sub {$pokemon->{types}->[1]->{type}->{name}}, "")
    });
  }
  my $message = <<EOF;


# POKEMON PAGE $self->{page}

EOF
  print($message);
  print pm_ui::table_as_ui($table);
}


sub command_get {
  my ($self) = @_;
  return {
    "n" => "Next page",
    "p" => "Previous page"
  };
}


sub input_handle {
  my ($self, $input_key) = @_;
  chomp $input_key;
  if ($input_key eq "n") {
    $self->_page_next();
  } elsif ($input_key eq "p") {
    $self->_page_previous();
  } else {
    main::print_event("Invalid key. ");
  }
}
