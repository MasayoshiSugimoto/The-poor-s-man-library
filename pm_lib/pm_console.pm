use strict;
use warnings;
package pm_console;


sub size_get {
  return $pm_constants::CONSOLE_SIZE_DEBUG if (defined $pm_constants::CONSOLE_SIZE_DEBUG);
  my ($height, $width) = split " ", `stty size`;
  return {x => $width, y => $height};
}

1;
