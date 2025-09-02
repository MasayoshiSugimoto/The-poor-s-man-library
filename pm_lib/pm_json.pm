package pm_json;
use strict;
use warnings;
use Scalar::Util qw(looks_like_number);
use constant {
  true => 1,
  false => 0
};


sub as_json {
  my ($x) = @_;
  if (!defined $x) {
    return "";
  }
  my $result = "";
  my $type = ref($x);
  pm_log::debug("ref(\$x)=$type");
  if ($type eq "HASH") {
    $result .= "{";
    my $first = true;
    foreach my $key (sort keys %$x) {
      my $v = as_json($x->{$key});
      if ($first) {
        $result .= "\"$key\":$v";
        $first = false;
      } else {
        $result .= ",\"$key\":$v";
      }
    }
    $result .= "}";
  } elsif ($type eq "ARRAY") {
    $result .= "[";
    my $first = true;
    foreach my $value (@$x) {
      my $v = as_json($value);
      if ($first) {
        $result .= "$v";
        $first = false;
      } else {
        $result .= ",$v";
      }
    }
    $result .= "]";
  } elsif ($type eq "SCALAR" && looks_like_number($x)) {  # Need something else for "1.0"
    $result = "$x";
  } elsif ($type eq "SCALAR") {
    $result = "\"$x\"";
  } elsif (!$type && looks_like_number($x)) {
    $result = "$x";
  } elsif (!$type) {
    $result = "\"$x\"";
  } else {
    die "Type $type not supported";
  }
  return $result;
}


1;
