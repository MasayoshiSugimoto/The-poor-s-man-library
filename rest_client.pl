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


my $result = pm_http_client->new('https://pokeapi.co/api/v2/pokemon/')
  ->get();
pm_log::info(pm_misc::as_text($result));
my $pokemons = $result->{results};
my $table = pm_table->new(['Name', 'Type 1', 'Type 2']);
$pokemons->for_each(sub {
  my ($pokemon_ref) = @_;
  my $pokemon = pm_http_client->new($pokemon_ref->{url})
    ->get();
  $table->push({
    'Name' => pm_function::call_or_default(sub {$pokemon->{name}}, ""),
    'Type 1' => pm_function::call_or_default(sub {$pokemon->{types}->get(0)->{type}->{name}}, ""),
    'Type 2' => pm_function::call_or_default(sub {$pokemon->{types}->get(1)->{type}->{name}}, "")
  });
});
print pm_md::table_as_markdown($table);
