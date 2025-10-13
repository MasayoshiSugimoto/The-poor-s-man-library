use strict;
use warnings;
use lib 'pm_lib';
use pm_include_test;


# Test layout
#
# A--------B------------------C
# | menu   | title            |
# |        D..................E
# |        | content          |
# |        |                  |
# F--------G------------------H

my $vertices = {
  A => {letter => "A", x => 0, y => 0},
  B => {letter => "B", x => 9, y => 0},
  C => {letter => "C", x => 28, y => 0},
  D => {letter => "D", x => 9, y => 2},
  E => {letter => "E", x => 28, y => 2},
  F => {letter => "F", x => 0, y => 5},
  G => {letter => "G", x => 9, y => 5},
  H => {letter => "H", x => 28, y => 5},
};
my $segments = [
  {vertices => ["D", "E"]},
  {vertices => ["D", "G"]},
  {vertices => ["E", "H"]},
  {vertices => ["F", "G"]},
  {vertices => ["B", "C"]},
  {vertices => ["B", "D"]},
  {vertices => ["A", "B"]},
  {vertices => ["A", "F"]},
  {vertices => ["G", "H"]},
  {vertices => ["C", "E"]},
];

my $tests = [
  {top_left => "A", expected => ["A", "B", "G", "F"]},
  {top_left => "B", expected => ["B", "C", "E", "D"]},
  {top_left => "C", expected => undef},
  {top_left => "D", expected => ["D", "E", "H", "G"]},
  {top_left => "E", expected => undef},
  {top_left => "F", expected => undef},
  {top_left => "G", expected => undef},
  {top_left => "H", expected => undef},
];

foreach my $test (@$tests) {
  my $component = pm_layout::component_extract($vertices, $segments, $test->{top_left});
  pm_test_util::assert_equals($test->{expected}, $component, "A");
}


