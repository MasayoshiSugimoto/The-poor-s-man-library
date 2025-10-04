use strict;
use warnings;
use lib 'pm_lib';
use pm_include_test;


my $layout_as_text;

$layout_as_text = <<EOF;
A--------B------------------C
| menu   | title            |
|        D..................E
|        | content          |
|        |                  |
F--------G------------------H
EOF


my $layout = pm_layout::from_string($layout_as_text);
$layout->render({
  menu => "a\nb\nc\nd",
  title => "TASKS",
  content => "Go to the super market"
});
my $expected_vertices = {
  A => {letter => "A", x => 0, y => 0},
  B => {letter => "B", x => 9, y => 0},
  C => {letter => "C", x => 28, y => 0},
  D => {letter => "D", x => 9, y => 2},
  E => {letter => "E", x => 28, y => 2},
  F => {letter => "F", x => 0, y => 5},
  G => {letter => "G", x => 9, y => 5},
  H => {letter => "H", x => 28, y => 5},
};
my $expected_segments = [
  {border => "-", vertices => ["A", "B"]},
  {border => "|", vertices => ["A", "F"]},
  {border => "-", vertices => ["B", "C"]},
  {border => "|", vertices => ["B", "D"]},
  {border => "|", vertices => ["C", "E"]},
  {border => ".", vertices => ["D", "E"]},
  {border => "|", vertices => ["D", "G"]},
  {border => "|", vertices => ["E", "H"]},
  {border => "-", vertices => ["F", "G"]},
  {border => "-", vertices => ["G", "H"]},
];
my $expected_components = [
  {anchor => "menu", rectangle => ["A", "B", "G", "F"]},
  {anchor => "title", rectangle => ["B", "C", "E", "D"]},
  {anchor => "content", rectangle => ["D", "E", "H", "G"]},
];
pm_test_util::assert_equals($expected_vertices, $layout->{vertices}, "vertices");
pm_test_util::assert_equals($expected_segments, $layout->{segments}, "segments");
pm_test_util::assert_equals($expected_components, $layout->{components}, "components");


