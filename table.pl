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
pm_arguments::flag_definition_set("-h", "HELP");
pm_arguments::flag_definition_set("--help", "HELP");
pm_arguments::flag_definition_set("-H", "HEADER");
pm_arguments::flag_definition_set("--header", "HEADER");
pm_arguments::flag_definition_set("-d", "DEBUG");
pm_arguments::flag_definition_set("--debug", "DEBUG");
pm_arguments::option_definition_set("-i", "INPUT_TYPE");
pm_arguments::option_definition_set("--input-type", "INPUT_TYPE");
pm_arguments::option_definition_set("-o", "OUTPUT_TYPE");
pm_arguments::option_definition_set("--output-type", "OUTPUT_TYPE");
pm_arguments::parse(@ARGV);

my $help = pm_arguments::flag_get("HELP");
my $header = pm_arguments::flag_get("HEADER");
my $debug = pm_arguments::flag_get("DEBUG");
my $input_type = pm_arguments::option_get("INPUT_TYPE");
my $output_type = pm_arguments::option_get("OUTPUT_TYPE");

if (!defined $input_type) {
  $input_type = "tsv";
}
$input_type = lc($input_type);
if (!defined $output_type) {
  $output_type = "md";
}
$output_type = lc($output_type);

if ($debug) {
  $pm_constants::LOG_DEBUG_ENABLE = true;
  pm_log::debug("PARAMETERS");
  pm_log::debug("==========");
  pm_log::debug();
  pm_log::debug("help=$help");
  pm_log::debug("header=$header");
  pm_log::debug("debug=$debug");
  pm_log::debug("input_type=$input_type");
  pm_log::debug("output_type=$output_type");
}

my $input = do { local $/; <STDIN> };
my $table;
if ($input_type eq "tsv") {
  $table = pm_csv::tsv_from_string($input, $header);
} elsif ($input_type eq "csv") {
  $table = pm_csv::csv_from_string($input, $header);
} elsif ($input_type eq "md") {
  $table = pm_md::parse_markdown_table($input);
}

if ($output_type eq "tsv") {
  print(pm_csv::as_tsv($table));
} elsif ($output_type eq "csv") {
  print(pm_csv::as_csv($table));
} elsif ($output_type eq "md") {
  print(pm_md::table_as_markdown($table));
}
