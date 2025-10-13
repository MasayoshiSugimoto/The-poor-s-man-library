use strict;
use warnings;
use lib 'pm_lib';
use pm_include_test;


my $layout_as_text;
my $layout;
my $expected_vertices;
my $expected_segments;
my $expected_components;

$layout_as_text = <<EOF;
A--------B------------------C
| menu   | title            |
|        D..................E
|        | content          |
|        |                  |
F--------G------------------H
EOF
$layout = pm_layout::from_string($layout_as_text);
$expected_vertices = {
  A => {letter => "A", x => 0, y => 0},
  B => {letter => "B", x => 9, y => 0},
  C => {letter => "C", x => 28, y => 0},
  D => {letter => "D", x => 9, y => 2},
  E => {letter => "E", x => 28, y => 2},
  F => {letter => "F", x => 0, y => 5},
  G => {letter => "G", x => 9, y => 5},
  H => {letter => "H", x => 28, y => 5},
};
$expected_segments = [
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
$expected_components = [
  {anchor => "menu", rectangle => ["A", "B", "G", "F"]},
  {anchor => "title", rectangle => ["B", "C", "E", "D"]},
  {anchor => "content", rectangle => ["D", "E", "H", "G"]},
];
pm_test_util::assert_equals($expected_vertices, $layout->{vertices}, "vertices");
pm_test_util::assert_equals($expected_segments, $layout->{segments}, "segments");
pm_test_util::assert_equals($expected_components, $layout->{components}, "components");


pm_log::separator();


$layout_as_text = <<EOF;
A--------B-------------------C
| menu   | title             |
|        D---------I---------E
|        | c1      | c2      |
K--------L         |         |
| menu2  |         |         |
F--------G---------J---------H
EOF
$layout = pm_layout::from_string($layout_as_text);
$layout->render({
  menu => "Menu",
  menu2 => "Menu2",
  title => "Title",
  c1 => "Content1",
  c2 => "Content2",
});
$expected_vertices = {
  A => {letter => "A", x => 0, y => 0},
  B => {letter => "B", x => 9, y => 0},
  C => {letter => "C", x => 29, y => 0},
  D => {letter => "D", x => 9, y => 2},
  E => {letter => "E", x => 29, y => 2},
  F => {letter => "F", x => 0, y => 6},
  G => {letter => "G", x => 9, y => 6},
  H => {letter => "H", x => 29, y => 6},
  I => {letter => "I", x => 19, y => 2},
  J => {letter => "J", x => 19, y => 6},
  K => {letter => "K", x => 0, y => 4},
  L => {letter => "L", x => 9, y => 4},
};
$expected_segments = [
  {border => "-", vertices => ["A", "B"]},
  {border => "|", vertices => ["A", "K"]},
  {border => "-", vertices => ["B", "C"]},
  {border => "|", vertices => ["B", "D"]},
  {border => "|", vertices => ["C", "E"]},
  {border => "-", vertices => ["D", "I"]},
  {border => "|", vertices => ["D", "L"]},
  {border => "|", vertices => ["E", "H"]},
  {border => "-", vertices => ["F", "G"]},
  {border => "-", vertices => ["G", "J"]},
  {border => "-", vertices => ["I", "E"]},
  {border => "|", vertices => ["I", "J"]},
  {border => "-", vertices => ["J", "H"]},
  {border => "-", vertices => ["K", "L"]},
  {border => "|", vertices => ["K", "F"]},
  {border => "|", vertices => ["L", "G"]},
];
$expected_components = [
  {anchor => "menu", rectangle => ["A", "B", "L", "K"]},
  {anchor => "title", rectangle => ["B", "C", "E", "D"]},
  {anchor => "c1", rectangle => ["D", "I", "J", "G"]},
  {anchor => "c2", rectangle => ["I", "E", "H", "J"]},
  {anchor => "menu2", rectangle => ["K", "L", "G", "F"]},
];
pm_test_util::assert_equals($expected_vertices, $layout->{vertices}, "vertices");
pm_test_util::assert_equals($expected_segments, $layout->{segments}, "segments");
pm_test_util::assert_equals($expected_components, $layout->{components}, "components");


