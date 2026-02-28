package pm_keyboard;

use strict;
use warnings;
use Exporter 'import';

our @EXPORT_OK = qw(
    KEYBOARD_ESC
    KEYBOARD_ENTER
    KEYBOARD_BACKSPACE
    KEYBOARD_TAB
    KEYBOARD_SPACE
    KEYBOARD_UP
    KEYBOARD_DOWN
    KEYBOARD_RIGHT
    KEYBOARD_LEFT
    KEYBOARD_SHIFT_UP
    KEYBOARD_SHIFT_DOWN
    KEYBOARD_SHIFT_RIGHT
    KEYBOARD_SHIFT_LEFT
    KEYBOARD_ALT_UP
    KEYBOARD_ALT_DOWN
    KEYBOARD_ALT_RIGHT
    KEYBOARD_ALT_LEFT
    KEYBOARD_CTRL_UP
    KEYBOARD_CTRL_DOWN
    KEYBOARD_CTRL_RIGHT
    KEYBOARD_CTRL_LEFT
    KEYBOARD_HOME
    KEYBOARD_END
    KEYBOARD_INSERT
    KEYBOARD_DELETE
    KEYBOARD_PAGE_UP
    KEYBOARD_PAGE_DOWN
    KEYBOARD_SHIFT_HOME
    KEYBOARD_SHIFT_END
    KEYBOARD_CTRL_HOME
    KEYBOARD_CTRL_END
    KEYBOARD_F1  KEYBOARD_F2  KEYBOARD_F3  KEYBOARD_F4
    KEYBOARD_F5  KEYBOARD_F6  KEYBOARD_F7  KEYBOARD_F8
    KEYBOARD_F9  KEYBOARD_F10 KEYBOARD_F11 KEYBOARD_F12
    KEYBOARD_SHIFT_F1  KEYBOARD_SHIFT_F2
    KEYBOARD_CTRL_F1   KEYBOARD_CTRL_F2
    KEYBOARD_ALT_F1    KEYBOARD_ALT_F2
    keyboard_consume_single
);

# -------------------------------------------------
# Basic keys
# -------------------------------------------------

use constant KEYBOARD_ESC       => "\x1B";
use constant KEYBOARD_ENTER     => "\x0D";
use constant KEYBOARD_BACKSPACE => "\x7F";
use constant KEYBOARD_TAB       => "\x09";
use constant KEYBOARD_SPACE     => " ";

# -------------------------------------------------
# Arrow keys (base)
# -------------------------------------------------

use constant KEYBOARD_UP    => "\x1B[A";
use constant KEYBOARD_DOWN  => "\x1B[B";
use constant KEYBOARD_RIGHT => "\x1B[C";
use constant KEYBOARD_LEFT  => "\x1B[D";

# -------------------------------------------------
# Arrow keys with modifiers (xterm CSI 1;<m>X)
# -------------------------------------------------

use constant KEYBOARD_SHIFT_UP    => "\x1B[1;2A";
use constant KEYBOARD_SHIFT_DOWN  => "\x1B[1;2B";
use constant KEYBOARD_SHIFT_RIGHT => "\x1B[1;2C";
use constant KEYBOARD_SHIFT_LEFT  => "\x1B[1;2D";

use constant KEYBOARD_ALT_UP      => "\x1B[1;3A";
use constant KEYBOARD_ALT_DOWN    => "\x1B[1;3B";
use constant KEYBOARD_ALT_RIGHT   => "\x1B[1;3C";
use constant KEYBOARD_ALT_LEFT    => "\x1B[1;3D";

use constant KEYBOARD_CTRL_UP     => "\x1B[1;5A";
use constant KEYBOARD_CTRL_DOWN   => "\x1B[1;5B";
use constant KEYBOARD_CTRL_RIGHT  => "\x1B[1;5C";
use constant KEYBOARD_CTRL_LEFT   => "\x1B[1;5D";

# -------------------------------------------------
# Navigation
# -------------------------------------------------

use constant KEYBOARD_HOME       => "\x1B[H";
use constant KEYBOARD_END        => "\x1B[F";
use constant KEYBOARD_INSERT     => "\x1B[2~";
use constant KEYBOARD_DELETE     => "\x1B[3~";
use constant KEYBOARD_PAGE_UP    => "\x1B[5~";
use constant KEYBOARD_PAGE_DOWN  => "\x1B[6~";

use constant KEYBOARD_SHIFT_HOME => "\x1B[1;2H";
use constant KEYBOARD_SHIFT_END  => "\x1B[1;2F";
use constant KEYBOARD_CTRL_HOME  => "\x1B[1;5H";
use constant KEYBOARD_CTRL_END   => "\x1B[1;5F";

# -------------------------------------------------
# Function keys (xterm)
# -------------------------------------------------

use constant KEYBOARD_F1  => "\x1BOP";
use constant KEYBOARD_F2  => "\x1BOQ";
use constant KEYBOARD_F3  => "\x1BOR";
use constant KEYBOARD_F4  => "\x1BOS";

use constant KEYBOARD_F5  => "\x1B[15~";
use constant KEYBOARD_F6  => "\x1B[17~";
use constant KEYBOARD_F7  => "\x1B[18~";
use constant KEYBOARD_F8  => "\x1B[19~";
use constant KEYBOARD_F9  => "\x1B[20~";
use constant KEYBOARD_F10 => "\x1B[21~";
use constant KEYBOARD_F11 => "\x1B[23~";
use constant KEYBOARD_F12 => "\x1B[24~";

# -------------------------------------------------
# Function keys with modifiers
# -------------------------------------------------

use constant KEYBOARD_SHIFT_F1 => "\x1B[1;2P";
use constant KEYBOARD_SHIFT_F2 => "\x1B[1;2Q";

use constant KEYBOARD_CTRL_F1  => "\x1B[1;5P";
use constant KEYBOARD_CTRL_F2  => "\x1B[1;5Q";

use constant KEYBOARD_ALT_F1   => "\x1B[1;3P";
use constant KEYBOARD_ALT_F2   => "\x1B[1;3Q";


sub keyboard_consume_single() {
  my $key = "";
  sysread(STDIN, $key, 1);
  if ($key eq KEYBOARD_ESC) {
    my $rin = "";
    vec($rin, fileno(STDIN), 1) = 1;
    return $key if (!select($rin, undef, undef, 0));
    sysread(STDIN, $key, 1);
    return $key if ($key ne "[");
    sysread(STDIN, $key, 1);
    return KEYBOARD_UP if ($key eq "A");
    return KEYBOARD_DOWN if ($key eq "B");
    return KEYBOARD_RIGHT if ($key eq "C");
    return KEYBOARD_LEFT if ($key eq "D");
  } else {
    return $key;
  }
}


1;
