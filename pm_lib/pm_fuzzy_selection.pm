package pm_fuzzy_selection;

use strict;
use warnings;
use pm_bool qw(true false);
use pm_ansi qw(ALT_SCREEN ALT_SCREEN_OFF BG_WHITE RESET SAVE_CURSOR RESTORE_CURSOR);
use pm_keyboard qw(
  KEYBOARD_UP
  KEYBOARD_RIGHT
  KEYBOARD_DOWN
  KEYBOARD_LEFT
  KEYBOARD_ESC
  KEYBOARD_BACKSPACE
  KEYBOARD_ENTER
  keyboard_consume_single
);


my $_selection_index = 0;


sub fuzzy_selection($) {
  my ($list) = @_;
  print(pm_ansi::ALT_SCREEN);
  $_selection_index = 0;
  my $pattern = "";
  my $result = "";
  while (true) {
    system("clear");
    print("> $pattern");
    print(SAVE_CURSOR);
    my $size = pm_console::size_get();
    my $fuzzy_pattern = join(".*", split(//, $pattern));
    my @filtered = grep { /$fuzzy_pattern/ } @$list;
    for (my $i = 0; $i < scalar @filtered && $i < $size->{y} - 1; $i++) {
      my $file = $filtered[$i];
      next if (!defined $file);
      my $color = $_selection_index == $i ? BG_WHITE : "";
      my $reset = RESET;
      print("\n$color$file$reset");
    }
    print(RESTORE_CURSOR);
    system("stty raw -echo");
    my $key = keyboard_consume_single();
    if ($key eq KEYBOARD_UP) {
      _selection_previous(\@filtered);
    } elsif ($key eq KEYBOARD_RIGHT) {
      # Do nothing
    } elsif ($key eq KEYBOARD_DOWN) {
      _selection_next(\@filtered);
    } elsif ($key eq KEYBOARD_LEFT) {
      # Do nothing
    } elsif ($key eq KEYBOARD_BACKSPACE) {
      $_selection_index = 0;
      chop($pattern);
    } elsif ($key eq KEYBOARD_ENTER) {
      $result = $filtered[$_selection_index];
      last;
    } else {
      $_selection_index = 0;
      $pattern .= $key;
    }
    system("stty -raw echo");
    last if ($key eq KEYBOARD_ESC);
    select(undef, undef, undef, 0.1);
  }
  print(pm_ansi::ALT_SCREEN_OFF);
  system("stty -raw echo");
  return $result;
}


sub _selection_next($) {
  my ($list) = @_;
  $_selection_index = ($_selection_index + 1) % (scalar @$list);
}


sub _selection_previous($) {
  my ($list) = @_;
  $_selection_index--;
  my $last = (scalar @$list) - 1;
  $last = 0 if ($last < 0);
  $_selection_index = $last if ($_selection_index < 0);
}


1;
