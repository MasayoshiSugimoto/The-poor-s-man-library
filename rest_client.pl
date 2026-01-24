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


sub pokemon_table_render {
  my $result = http_get('https://pokeapi.co/api/v2/pokemon/');
  my $pokemons = $result->{results};
  my $table = pm_table->new(['Name', 'Type 1', 'Type 2']);
  $pokemons->for_each(sub {
    my ($pokemon_ref) = @_;
    my $pokemon = http_get($pokemon_ref->{url});
    $table->push({
      'Name' => pm_function::call_or_default(sub {$pokemon->{name}}, ""),
      'Type 1' => pm_function::call_or_default(sub {$pokemon->{types}->get(0)->{type}->{name}}, ""),
      'Type 2' => pm_function::call_or_def ault(sub {$pokemon->{types}->get(1)->{type}->{name}}, "")
    });
  });
  print pm_md::table_as_markdown($table);
}


sub pokemons_render {
  my $result = http_get('https://pokeapi.co/api/v2/pokemon/');
  println();
  print_event("JSON Output:");
  print(pm_json::as_pretty_json($result, "  "));
}


sub pokemons_query {
  if ($STATE->{url} eq 'https://pokeapi.co/api/v2/pokemon/') {
    print_event("Querying pokemon list (page:1).");
    my $result = http_get('https://pokeapi.co/api/v2/pokemon/');
    pm_log::info(pm_misc::as_text($result));
    my $pokemons = $result->{results};
    my $table = pm_table->new(['Name', 'Type 1', 'Type 2']);
    foreach my $pokemon_ref (@$pokemons) {
      my $pokemon = http_get($pokemon_ref->{url});
      $table->push({
        'Name' => pm_function::call_or_default(sub {$pokemon->{name}}, ""),
        'Type 1' => pm_function::call_or_default(sub {$pokemon->{types}->[0]->{type}->{name}}, ""),
        'Type 2' => pm_function::call_or_default(sub {$pokemon->{types}->[1]->{type}->{name}}, "")
      });
    }
    my $message = <<EOF;

POKEMON PAGE 1
==============

EOF
    print($message);
    print pm_ui::table_as_ui($table);
  } else {
    pm_assert::assert_fail("Unknown url");
  }
}


sub header_render {
  print_event("Calling $STATE->{url}");
}


sub prompt_commands_render {
  my ($commands) = @_;
  print_event("Select command:");
  foreach my $key (sort keys %$commands) {
    my $description = $commands->{$key};
    print("$key: ${description}\n");
  }
}


sub instruction_render {
  my $commands = {
    A => "Command A",
    B => "Command B",
    C => "Command C"
  };
  prompt_commands_render($commands);
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
  #header_render();
  #pokemon_table_render();
  #print("> Querying");
  #pokemons_query();
  #println();
  #println();
  #instruction_render();
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


sub url_get {
  my ($self) = @_;
  my $offset = $self->{page} * $self->{page_size};
  my $limit = $self->{page_size};
  return "$self->{url}/?offset=$offset&limit=$limit"
}


sub page_next {
  my ($self) = @_;
  $self->{page}++;
  return $self;
}


sub page_previous {
  my ($self) = @_;
  $self->{page}--;
  return $self;
}


sub update {
  my ($self) = @_;
  main::print_event("Querying pokemon list (page:$self->{page}).");
  my $url = $self->url_get();
  my $result = main::http_get($url);
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
    $self->page_next();
  } elsif ($input_key eq "p") {
    $self->page_previous();
  } else {
    main::print_event("Invalid key. ");
  }
}
