use strict;
use warnings;
use lib 'pm_lib';
use pm_include_test;


$pm_constants::CONSOLE_SIZE_DEBUG = {x => 21, y => 10};
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


$layout = pm_layout::from_string($layout_as_text)
  ->solve({
    size => {
      width => "100%",  # 100% of the terminal size
      height => "100%"
    },
    ABGF => {
      width => "50%"
    },
    BCED => {
      horizontal_alignment => "center",
      vertical_alignment => "center",
      height =>  3  # Number of rows (Without borders)
    }
  });
$expected_vertices = {
  A => {letter => "A", x => 0, y => 0},
  B => {letter => "B", x => 9, y => 0},
  C => {letter => "C", x => 20, y => 0},
  D => {letter => "D", x => 9, y => 2},
  E => {letter => "E", x => 20, y => 2},
  F => {letter => "F", x => 0, y => 9},
  G => {letter => "G", x => 9, y => 9},
  H => {letter => "H", x => 20, y => 9},
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
A--------B
|        |
C--------D
|        |
E--------F
|        |
G--------H
EOF


$layout = pm_layout::from_string($layout_as_text)
  ->solve({
    size => {
      width => "100%",  # 100% of the terminal size
      height => "100%"
    },
    EFGH => {
      height =>  3  # Number of rows (Without borders)
    }
  })
  ->render({});
$expected_vertices = {
  A => {letter => "A", x => 0, y => 0},
  B => {letter => "B", x => 9, y => 0},
  C => {letter => "C", x => 20, y => 0},
  D => {letter => "D", x => 9, y => 2},
  E => {letter => "E", x => 20, y => 2},
  F => {letter => "F", x => 0, y => 9},
  G => {letter => "G", x => 9, y => 9},
  H => {letter => "H", x => 20, y => 9},
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
#pm_test_util::assert_equals($expected_vertices, $layout->{vertices}, "vertices");
#pm_test_util::assert_equals($expected_segments, $layout->{segments}, "segments");
#pm_test_util::assert_equals($expected_components, $layout->{components}, "components");


$pm_constants::CONSOLE_SIZE_DEBUG = undef;
