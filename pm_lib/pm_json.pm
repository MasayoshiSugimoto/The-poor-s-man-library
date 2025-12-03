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
    return "null";
  }
  my $result = "";
  my $type = ref($x);
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
  } elsif ($type eq "SCALAR" && looks_like_number($x) && $x =~ /^0\d.*/) {  # Prevent number with leading zero to be interpreted as numbers.
    $result = "\"$x\"";
  } elsif ($type eq "SCALAR" && looks_like_number($x)) {  # Need something else for "1.0"
    $result = "$x";
  } elsif ($type eq "SCALAR") {
    $result = "\"$x\"";
  } elsif (!$type && looks_like_number($x) && $x =~ /^0\d.*/) {  # Prevent number with leading zero to be interpreted as numbers.
    $result = "\"$x\"";
  } elsif (!$type && looks_like_number($x)) {
    $result = "$x";
  } elsif (!$type) {
    $result = "\"$x\"";
  } else {
    die pm_log::exception("Type $type not supported");
  }
  return $result;
}


sub parse {
  my ($text) = @_;
  return undef if ($text eq "");
  $text =~ s/^[\n\s]+|[\n\s]+$//g;
  my $pos = 0;
  my $parse_value;
  my $parse_object;
  my $parse_array;
  my $parse_string;
  my $parse_number;
  my $parse_literal;

  $parse_value = sub  {
    pm_log::debug("parse_value");
    $text =~ /\G[\s\n]*/gc;
    return $parse_object->() if $text =~ /\G\{/;
    return $parse_array->()  if $text =~ /\G\[/;
    return $parse_string->() if $text =~ /\G\"/;
    return $parse_number->() if $text =~ /\G-?\d/;
    return $parse_literal->() if $text =~ /\G(?:true|false|null)/;
    die pm_log::exception("Unexpected token at position $pos");
  };

  $parse_object = sub {
    pm_log::debug("parse_object");
    my %obj;
    $text =~ /\G\{/gc;
    $text =~ /\G[\n\s]*/gc;
    until ($text =~ /\G\}/gc) {
      $text =~ /\G[\n\s]*/gc;
      my $key = $parse_string->();
      if ($text =~ /\G[\n\s]*:[\n\s]*/gc) {
      } elsif ($text =~ /\G(.*)/) {
        die "Expected ':', found: $1";
      } else {
        die "Expected ':'"
      }
      my $value = $parse_value->();
      pm_log::debug("key=$key, value=$value");
      $obj{$key} = $value;
      $text =~ /\G[\n\s]*/gc;
      last if $text =~ /\G\}/gc;
      $text =~ /\G,/gc or die "Expected ',' or '}'";
    }
    return \%obj;
  };

  $parse_array = sub {
    pm_log::debug("parse_array");
    my @arr;
    $text =~ /\G\[/gc;
    $text =~ /\G[\n\s]*/gc;
    until ($text =~ /\G\]/gc) {
      push @arr, $parse_value->();
      $text =~ /\G[\n\s]*/gc;
      last if $text =~ /\G\]/gc;
      $text =~ /\G,/gc or die "Expected ',' or ']'";
    }
    my $list = pm_list->new(\@arr);
    pm_log::debug($list->as_text());
    return $list;
  };

  $parse_string = sub {
    pm_log::debug("parse_string");
    $text =~ /\G"/gc;
    my $str = '';
    while ($text =~ /\G([^"\\]*)/gc) {
      $str .= $1;
      pm_log::debug("str=$str");
      if ($text =~ /\G\"/gc) {
        last;
      } elsif ($text =~ /\G\\(.)/gc) {
        my $esc = $1;
        $str .= $esc eq 'n' ? "\n" :
        $esc eq 't' ? "\t" :
        $esc eq 'r' ? "\r" :
        $esc eq '"' ? '"' :
        $esc eq '\\' ? '\\' : $esc;
      }
    }
    pm_log::debug("String found: $str");
    return $str;
  };

  $parse_number = sub {
    pm_log::debug("parse_number");
    $text =~ /\G(-?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?)/gc;
    pm_log::debug("Number found: $1");
    return 0 + $1;
  };

  $parse_literal = sub {
    pm_log::debug("parse_literal");
    pm_log::debug($text);
    if ($text =~ /\Gtrue/gc) {
      pm_log::debug("Boolean found: true");
      return true;
    } elsif ($text =~ /\Gfalse/gc) {
      pm_log::debug("Boolean found: false");
      return false;
    } elsif ($text =~ /\Gnull/gc) {
      pm_log::debug("null found");
      return undef;
    } else {
      $text =~ /\G(.*)/gc;
      die "Expecting literal: [true, false, null], found: $1";
    }
  };

  return $parse_value->();
}


sub json_as_table {
  my ($json) = @_;
  pm_assert::assert_equals("pm_list", ref($json), "Input json must be an array.");
  pm_assert::assert_true($json->size() > 0, "Input json cannot be an empty array.");
  # Extract header
  my $raw_header = $json->get(0);
  pm_assert::assert_equals("HASH", ref($raw_header), "Input json must be a list of hash.");
  my $header = pm_list->new();
  for my $key (keys %{$raw_header}) {
    pm_log::debug("key=$key");
    $header->push($key);
  }
  my $header_as_text = $header->as_text();
  pm_log::debug("header=$header_as_text");
  # Extract data
  my $as_array = sub {
    my ($record) = @_;
    my $result = $header->map(sub {$record->{$_[0]}});
    pm_log::debug($result->as_text());
    return $result->as_array();
  };
  pm_log::debug("data=");
  my $data = $json->map($as_array)
    ->as_array();
  return pm_table->new($header, $data);
}


1;
