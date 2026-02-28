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


my $ALTERNATE_SCREEN_OPEN = "\e[?1049h";
my $ALTERNATE_SCREEN_CLOSE = "\e[?1049l";
my $KEY_ID_ESCAPE = 27;


sub key_consume {
  my $key = "";
  sysread(STDIN, $key, 1);
  if ($key eq '') {

  } elsif ($key eq '') {

  } else {
    return $key;
  }
}


my @files = split(/\n/, `find`);
print($ALTERNATE_SCREEN_OPEN);
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
    print("\n$file");
  }
  system("stty raw -echo");
  my $key = "";
  sysread(STDIN, $key, 1);
  $pattern .= $key;
  system("stty -raw echo");
  last if (ord($key) == $KEY_ID_ESCAPE);
}
print($ALTERNATE_SCREEN_CLOSE);
