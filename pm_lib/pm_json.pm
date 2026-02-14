package pm_json;
use strict;
use warnings FATAL => 'uninitialized';
use Scalar::Util qw(looks_like_number);
use constant {
  true => 1,
  false => 0
};


sub as_json {
  my ($x, $schema) = @_;
  return as_pretty_json($x, $schema, "", "", "");
}


sub as_pretty_json {
  my ($x, $schema, $indent_increment, $indent, $new_line) = @_;
  return "null" if (!defined $x);
  $indent_increment = "  " if (!defined $indent_increment);
  $indent = "" if (!defined $indent);
  $new_line = "\n" if (!defined $new_line);
  my $space = "";
  $space = " " if (length($indent_increment) > 0);
  my $result = "";
  my $type = ref($x);
  if ($type eq "HASH") {
    my $indent2 = $indent . $indent_increment;
    $result .= "\{$new_line";
    my $first = true;
    foreach my $key (sort keys %$x) {
      my $v = as_pretty_json($x->{$key}, $schema && $schema->{$key}, $indent_increment, $indent2, $new_line);
      if ($first) {
        $result .= "$indent2\"$key\":$space$v";
        $first = false;
      } else {
        $result .= ",$new_line$indent2\"$key\":$space$v";
      }
    }
    $result .= "$new_line$indent}";
  } elsif ($type eq "ARRAY") {
    my $indent2 = $indent . $indent_increment;
    $result .= "$indent\[$new_line";
    my $first = true;
    foreach my $value (@$x) {
      my $v = as_pretty_json($value, $schema && $schema->[0], $indent_increment, $indent2, $new_line);
      if ($first) {
        $result .= "$indent2$v";
        $first = false;
      } else {
        $result .= ",$new_line$indent2$v";
      }
    }
    $result .= "$new_line$indent]";
  } elsif ($type eq "SCALAR" && defined $schema && $schema eq "string") {
    $result = "\"$x\"";
  } elsif ($type eq "SCALAR" && defined $schema && $schema eq "number") {
    $x = 0 + $x;
    $result = "$x";
  } elsif ($type eq "SCALAR" && defined $schema && $schema eq "boolean") {
    $result = $x ? "true" : "false";
  } elsif (!$type && defined $schema && $schema eq "string") {
    $result = "\"$x\"";
  } elsif (!$type && defined $schema && $schema eq "number") {
    $x = 0 + $x;
    $result = "$x";
  } elsif (!$type && defined $schema && $schema eq "boolean") {
    $result = $x ? "true" : "false";
  } elsif ($type eq "SCALAR" && looks_like_number($x)) {  # Maybe replace by assert?
    $x = 0 + $x;
    $result = "$x";
  } elsif ($type eq "SCALAR") {
    $result = "\"$x\"";
  } elsif (!$type && looks_like_number($x)) {
    $x = 0 + $x;
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
    $text =~ /\G[\s\n]*/gc;
    return $parse_object->() if $text =~ /\G\{/;
    return $parse_array->()  if $text =~ /\G\[/;
    return $parse_string->() if $text =~ /\G\"/;
    return $parse_number->() if $text =~ /\G-?\d/;
    return $parse_literal->() if $text =~ /\G(?:true|false|null)/;
    die pm_log::exception("Unexpected token at position $pos");
  };

  $parse_object = sub {
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
      $obj{$key} = $value;
      $text =~ /\G[\n\s]*/gc;
      last if $text =~ /\G\}/gc;
      $text =~ /\G,/gc or die "Expected ',' or '}'";
    }
    return \%obj;
  };

  $parse_array = sub {
    my @arr;
    $text =~ /\G\[/gc;
    $text =~ /\G[\n\s]*/gc;
    until ($text =~ /\G\]/gc) {
      push @arr, $parse_value->();
      $text =~ /\G[\n\s]*/gc;
      last if $text =~ /\G\]/gc;
      $text =~ /\G,/gc or die "Expected ',' or ']'";
    }
    return \@arr;
  };

  $parse_string = sub {
    $text =~ /\G"/gc;
    my $str = '';
    while ($text =~ /\G([^"\\]*)/gc) {
      $str .= $1;
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
    return $str;
  };

  $parse_number = sub {
    $text =~ /\G(-?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?)/gc;
    return 0 + $1;
  };

  $parse_literal = sub {
    if ($text =~ /\Gtrue/gc) {
      return true;
    } elsif ($text =~ /\Gfalse/gc) {
      return false;
    } elsif ($text =~ /\Gnull/gc) {
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
  pm_assert::assert_equals("ARRAY", ref($json), "Input json must be an array.");
  pm_assert::assert_true(scalar @$json > 0, "Input json cannot be an empty array.");
  # Extract header
  my $raw_header = $json->[0];
  pm_assert::assert_equals("HASH", ref($raw_header), "Input json must be a list of hash.");
  my $header = pm_list->new();
  for my $key (keys %{$raw_header}) {
    $header->push($key);
  }
  my $header_as_text = $header->as_text();
  # Extract data
  my $as_array = sub {
    my ($record) = @_;
    my $result = $header->map(sub {$record->{$_[0]}});
    return $result->as_array();
  };
  my $data = pm_list->new($json)
    ->map($as_array)
    ->as_array();
  return pm_table->new($header, $data);
}


1;
