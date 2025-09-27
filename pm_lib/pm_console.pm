use strict;
use warnings;
package pm_console;


sub size_get {
  my ($height, $width) = split " ", `stty size`;
  return {x => $width, y => $height};
}

1;
