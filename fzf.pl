#!/usr/bin/perl
use strict;
use warnings;
use lib '.';
use lib 'pm_lib';
use pm_include;
use constant {
  true => 1,
  false => 0
};
use pm_ansi qw(ALT_SCREEN ALT_SCREEN_OFF BG_WHITE RESET SAVE_CURSOR RESTORE_CURSOR);
use pm_keyboard qw(
  KEYBOARD_UP
  KEYBOARD_RIGHT
  KEYBOARD_DOWN
  KEYBOARD_LEFT
  KEYBOARD_ESC
  KEYBOARD_BACKSPACE
  keyboard_consume_single
);


my $selection_index = 0;


sub selection_next($) {
  my ($list) = @_;
  $selection_index = ($selection_index + 1) % (scalar @$list);
}


sub selection_previous($) {
  my ($list) = @_;
  $selection_index--;
  my $last = (scalar @$list) - 1;
  $last = 0 if ($last < 0);
  $selection_index = $last if ($selection_index < 0);
}


my @files = split(/\n/, `find`);
my $selection = pm_fuzzy_selection::fuzzy_selection(\@files);
print($selection);
print("\n");
