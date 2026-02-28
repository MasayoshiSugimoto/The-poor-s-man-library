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
use pm_ansi qw(ALT_SCREEN ALT_SCREEN_OFF BG_WHITE RESET);
use pm_keyboard qw(
  KEYBOARD_UP
  KEYBOARD_RIGHT
  KEYBOARD_DOWN
  KEYBOARD_LEFT
  KEYBOARD_ESC
  keyboard_consume_single
);


my $KEY_ID_ESCAPE = 27;
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
print(ALT_SCREEN);
my $pattern = "";
while (true) {
  system("clear");
  print("> $pattern");
  my $size = pm_console::size_get();
  my $fuzzy_pattern = join(".*", split(//, $pattern));
  my @filtered = grep { /$fuzzy_pattern/ } @files;
  for (my $i = 0; $i < scalar @filtered && $i < $size->{y} - 1; $i++) {
    my $file = $filtered[$i];
    next if (!defined $file);
    my $color = $selection_index == $i ? BG_WHITE : "";
    my $reset = RESET;
    print("\n$color$file$reset");
  }
  system("stty raw -echo");
  my $key = keyboard_consume_single();
  if ($key eq KEYBOARD_UP) {
    selection_previous(\@filtered);
  } elsif ($key eq KEYBOARD_RIGHT) {
    # Do nothing
  } elsif ($key eq KEYBOARD_DOWN) {
    selection_next(\@filtered);
  } elsif ($key eq KEYBOARD_LEFT) {
    # Do nothing
  } else {
    $pattern .= $key;
  }
  system("stty -raw echo");
  last if ($key eq KEYBOARD_ESC);
  select(undef, undef, undef, 0.1);
}
print(ALT_SCREEN_OFF);
