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


$pm_constants::LOG_DEBUG_ENABLE = false;
my $PATH = 'pokeapi.co/api/v2/pokemon';


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


sub header_render {
  print_event("Calling $PATH");
}


sub instruction_render {
  print_event("Select command:");
  my $commands = {
    A => "Command A",
    B => "Command B",
    C => "Command C"
  };

  my $table = pm_table->new(['Key', 'Command']);
  foreach my $key (keys %$commands) {
    $table->push({
        "Key" => $key,
        "Command" => $commands->{$key}
    });
  }
  print pm_md::table_as_markdown($table);
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
  header_render();
  #pokemon_table_render();
  print("> Querying");
  pokemons_render();
  println();
  println();
  instruction_render();
  my $line = <STDIN>;
}


run();
