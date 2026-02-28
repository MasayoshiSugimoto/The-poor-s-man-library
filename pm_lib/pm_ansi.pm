package pm_ansi;

use strict;
use warnings;
use Exporter 'import';


our @EXPORT_OK = qw(
    ESC BEL CSI OSC ST
    CLEAR_SCREEN CLEAR_LINE
    ALT_SCREEN ALT_SCREEN_OFF
    SAVE_CURSOR RESTORE_CURSOR
    HIDE_CURSOR SHOW_CURSOR
    RESET BOLD FAINT ITALIC UNDERLINE BLINK RAPID_BLINK
    INVERSE HIDDEN STRIKE
    FG_BLACK FG_RED FG_GREEN FG_YELLOW FG_BLUE FG_MAGENTA FG_CYAN FG_WHITE
    FG_DEFAULT
    BG_BLACK BG_RED BG_GREEN BG_YELLOW BG_BLUE BG_MAGENTA BG_CYAN BG_WHITE
    BG_DEFAULT
    FG_BRIGHT_BLACK FG_BRIGHT_RED FG_BRIGHT_GREEN FG_BRIGHT_YELLOW
    FG_BRIGHT_BLUE FG_BRIGHT_MAGENTA FG_BRIGHT_CYAN FG_BRIGHT_WHITE
    BG_BRIGHT_BLACK BG_BRIGHT_RED BG_BRIGHT_GREEN BG_BRIGHT_YELLOW
    BG_BRIGHT_BLUE BG_BRIGHT_MAGENTA BG_BRIGHT_CYAN BG_BRIGHT_WHITE
);


# -------------------------------------------------
# Base control characters
# -------------------------------------------------

use constant ESC => "\x1B";
use constant BEL => "\x07";

use constant CSI => "\x1B[";
use constant OSC => "\x1B]";
use constant ST  => "\x1B\\";

# -------------------------------------------------
# Screen / cursor control
# -------------------------------------------------

use constant CLEAR_SCREEN => "\x1B[2J";
use constant CLEAR_LINE   => "\x1B[2K";

use constant ALT_SCREEN      => "\x1B[?1049h";
use constant ALT_SCREEN_OFF  => "\x1B[?1049l";

use constant SAVE_CURSOR     => "\x1B[s";
use constant RESTORE_CURSOR  => "\x1B[u";

use constant HIDE_CURSOR     => "\x1B[?25l";
use constant SHOW_CURSOR     => "\x1B[?25h";

# -------------------------------------------------
# SGR (Select Graphic Rendition)
# -------------------------------------------------

use constant RESET        => "\x1B[0m";
use constant BOLD         => "\x1B[1m";
use constant FAINT        => "\x1B[2m";
use constant ITALIC       => "\x1B[3m";
use constant UNDERLINE    => "\x1B[4m";
use constant BLINK        => "\x1B[5m";
use constant RAPID_BLINK  => "\x1B[6m";
use constant INVERSE      => "\x1B[7m";
use constant HIDDEN       => "\x1B[8m";
use constant STRIKE       => "\x1B[9m";

# -------------------------------------------------
# Standard 8 colors (foreground)
# -------------------------------------------------

use constant FG_BLACK   => "\x1B[30m";
use constant FG_RED     => "\x1B[31m";
use constant FG_GREEN   => "\x1B[32m";
use constant FG_YELLOW  => "\x1B[33m";
use constant FG_BLUE    => "\x1B[34m";
use constant FG_MAGENTA => "\x1B[35m";
use constant FG_CYAN    => "\x1B[36m";
use constant FG_WHITE   => "\x1B[37m";
use constant FG_DEFAULT => "\x1B[39m";

# -------------------------------------------------
# Standard 8 colors (background)
# -------------------------------------------------

use constant BG_BLACK   => "\x1B[40m";
use constant BG_RED     => "\x1B[41m";
use constant BG_GREEN   => "\x1B[42m";
use constant BG_YELLOW  => "\x1B[43m";
use constant BG_BLUE    => "\x1B[44m";
use constant BG_MAGENTA => "\x1B[45m";
use constant BG_CYAN    => "\x1B[46m";
use constant BG_WHITE   => "\x1B[47m";
use constant BG_DEFAULT => "\x1B[49m";

# -------------------------------------------------
# Bright foreground colors
# -------------------------------------------------

use constant FG_BRIGHT_BLACK   => "\x1B[90m";
use constant FG_BRIGHT_RED     => "\x1B[91m";
use constant FG_BRIGHT_GREEN   => "\x1B[92m";
use constant FG_BRIGHT_YELLOW  => "\x1B[93m";
use constant FG_BRIGHT_BLUE    => "\x1B[94m";
use constant FG_BRIGHT_MAGENTA => "\x1B[95m";
use constant FG_BRIGHT_CYAN    => "\x1B[96m";
use constant FG_BRIGHT_WHITE   => "\x1B[97m";

# -------------------------------------------------
# Bright background colors
# -------------------------------------------------

use constant BG_BRIGHT_BLACK   => "\x1B[100m";
use constant BG_BRIGHT_RED     => "\x1B[101m";
use constant BG_BRIGHT_GREEN   => "\x1B[102m";
use constant BG_BRIGHT_YELLOW  => "\x1B[103m";
use constant BG_BRIGHT_BLUE    => "\x1B[104m";
use constant BG_BRIGHT_MAGENTA => "\x1B[105m";
use constant BG_BRIGHT_CYAN    => "\x1B[106m";
use constant BG_BRIGHT_WHITE   => "\x1B[107m";

1;
