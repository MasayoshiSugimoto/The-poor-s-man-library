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


my $coffees = pm_http_client->new('https://api.sampleapis.com/coffee/hot')
  ->get();
pm_log::info(pm_misc::as_text($coffees));
my $table = pm_table->new(['id', 'title', 'description']);
$coffees->for_each(sub {
  my ($receipe) = @_;
  $table->push({
    id => $receipe->{id},
    title => $receipe->{title},
    description =>  substr($receipe->{description}, 0, 30)
  })
});
print pm_md::table_as_markdown($table);
