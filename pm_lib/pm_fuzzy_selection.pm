package pm_fuzzy_selection;


use strict;
use warnings;
use pm_bool qw(true false);
use pm_ansi qw(ALT_SCREEN ALT_SCREEN_OFF BG_WHITE RESET SAVE_CURSOR RESTORE_CURSOR FG_DEFAULT CLEAR_SCREEN);
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
my $_offset = 0;


sub fuzzy_selection($) {
  my ($list) = @_;
  eval { _fuzzy_selection($list); };
}


sub _fuzzy_selection($) {
  my ($list) = @_;
  _print(pm_ansi::ALT_SCREEN);
  $_selection_index = 0;
  $_offset = 0;
  my $pattern = "";
  my $result = "";
  while (true) {
    _print(pm_ansi::HIDE_CURSOR);
    _print(pm_ansi::CLEAR_SCREEN);
    _print(pm_ansi::cursor_position_set(0, 0));
    _print("> $pattern");
    my $size = pm_console::size_get();
    my $fuzzy_pattern = join("(.*)", split(//, $pattern));
    my @filtered = grep { /$fuzzy_pattern/i } @$list;
    my $filtered_count = scalar @filtered;
    my $height = $size->{y} - 1;
    if ($_selection_index < $_offset) {
      $_offset = $_selection_index;
    }
    if ($_selection_index >= $_offset + $height) {
      $_offset = $_selection_index - $height + 1;
    }
    for (my $i = 0; $i + $_offset < $filtered_count && $i < $height; $i++) {
      my $x = $_offset + $i;
      my $file = _colorize($filtered[$x], $pattern);
      next if (!defined $file);
      my $color = $_selection_index == $x ? $pm_constants::COLOR_SELECTION : "";
      my $reset = RESET;
      _print("\n$color$file$reset");
    }
    _print(pm_ansi::SHOW_CURSOR);
    _print(pm_ansi::cursor_position_set(3 + length($pattern), 0));
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
      $_offset = 0;
      chop($pattern);
    } elsif ($key eq KEYBOARD_ENTER) {
      $result = $filtered[$_selection_index];
      last;
    } else {
      $_selection_index = 0;
      $_offset = 0;
      $pattern .= $key;
    }
    system("stty -raw echo");
    last if ($key eq KEYBOARD_ESC);
    select(undef, undef, undef, 0.1);
  }
  _print(pm_ansi::ALT_SCREEN_OFF);
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


sub _as_fuzzy_pattern($) {
  my ($pattern) = @_;
  return join(".*", split(//, $pattern));
}


sub _colorize($$) {
  my ($string, $pattern) = @_;
  my @p = split(//, $pattern);
  my @s = split(//, $string);
  my $result = "";
  my $index = 0;
  my $reset = FG_DEFAULT;
  foreach my $char (@s) {
    if ($index < scalar @p && lc($char) eq lc($p[$index])) {
      $index++;
      $result .= "$pm_constants::COLOR_MATCH$char$reset";
    } else {
      $result .= $char
    }
  }
  return $result;
}


sub _print {
  my ($text) = @_;
  print STDERR $text;
}


1;
