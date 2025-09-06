use strict;
use warnings;
use lib 'pm_lib';
use pm_include_test;


my $text;
my $csv;
$text = <<EOF;
First Name,Last Name,Tel
Jean,Dupond,1234567
Michel,Durand,2345678
Giselle,Proust,3456789
EOF
pm_log::debug("text=$text");
$csv = pm_csv::from_string($text, $pm_csv::HEADER_ON);
pm_assert::assert_equals(3, $csv->size(), "Incorrect number of records");
pm_assert::assert_equals(
  {
    'First Name' => 'Jean',
    'Last Name' => 'Dupond',
    'Tel' => 1234567
  },
  $csv->get(0),
  "Jean Dupon"
);
pm_assert::assert_equals(
  {
    'First Name' => 'Michel',
    'Last Name' => 'Durand',
    'Tel' => 2345678
  },
  $csv->get(1),
  "Michel Durand"
);
pm_assert::assert_equals(
  {
    'First Name' => 'Giselle',
    'Last Name' => 'Proust',
    'Tel' => 3456789
  },
  $csv->get(2),
  "Giselle Proust"
);

pm_log::separator();

$text = <<EOF;
Jean,Dupond,1234567
Michel,Durand,2345678
Giselle,Proust,3456789
EOF
pm_log::debug("text=$text");
$csv = pm_csv::from_string($text, $pm_csv::HEADER_OFF);
pm_assert::assert_equals(3, $csv->size(), "Incorrect number of records");
pm_assert::assert_equals(
  {
    'c0' => 'Jean',
    'c1' => 'Dupond',
    'c2' => 1234567
  },
  $csv->get(0),
  "Jean Dupon"
);
pm_assert::assert_equals(
  {
    'c0' => 'Michel',
    'c1' => 'Durand',
    'c2' => 2345678
  },
  $csv->get(1),
  "Michel Durand"
);
pm_assert::assert_equals(
  {
    'c0' => 'Giselle',
    'c1' => 'Proust',
    'c2' => 3456789
  },
  $csv->get(2),
  "Giselle Proust"
);
pm_log::separator();
