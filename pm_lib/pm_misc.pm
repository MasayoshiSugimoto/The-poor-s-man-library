use strict;
use warnings;
package pm_misc;
use constant {
  true => 1,
  false => 0
};


sub equals {
  my ($a, $b) = @_;

  $a = normalize($a);
  $b = normalize($b);

  # Compare undefined values
  return true if !defined($a) && !defined($b);
  return false if !defined($a) || !defined($b);
  # Compare references
  if (ref($a) || ref($b)) {
    return false if ref($a) ne ref($b);
    if (ref($a) eq 'ARRAY') {
      return false if (scalar @$a != scalar @$b);
      for (my $i = 0; $i < scalar @$a; $i++) {
        return false if (!equals($a->[$i], $b->[$i]));
      }
      return true;
    } elsif (ref($a) eq 'HASH') {
      return false unless keys %$a == keys %$b;
      for my $key (keys %$a) {
        return false unless exists $b->{$key};
        return false unless equals($a->{$key}, $b->{$key});
      }
      return true;
    } elsif (ref($a) eq 'SCALAR') {
      return equals($$a, $$b);
    } elsif (ref($a) eq 'CODE') {
      return $a == $b;
    } else {
      return $a == $b;
    }
  }

  # Compare scalars: numeric if both look like numbers, else string
  if ($a =~ /^-?\d+(\.\d+)?$/ && $b =~ /^-?\d+(\.\d+)?$/) {
    return $a == $b;
  } else {
    return $a eq $b;
  }
}


sub normalize {
  my ($x) = @_;
  my $refX = ref($x);
  return $x if (!defined $x);
  return $x if (!ref($x));
  return $x if ($refX eq 'ARRAY');
  return $x if ($refX eq 'HASH');
  return $x if ($refX eq 'SCALAR');
  return $x if ($refX eq 'CODE');
  return $x->normalize() if ($x->can('normalize'));
  return $x;
}


sub as_text {
  my ($x, $indent) = @_;
  $indent = "" if (!defined $indent);
  return "undef" if (!defined $x);
  my $refX = ref($x);
  if ($refX eq 'ARRAY') {
    my $result = "[\n";
    my $first = true;
    for my $i (@$x) {
      my $value = as_text($i, "  $indent");
      if ($first) {
        $result .= "$indent  $value";
        $first = false;
      } else {
        $result .= ",\n$indent  $value";
      }
    }
    $result .= "\n$indent]";
    return $result;
  }
  if ($refX eq 'HASH') {
    my $result = "{";
    my $first = true;
    foreach my $key (sort keys %$x) {
      my $value = as_text($x->{$key});
      if ($first) {
        $result .= "$key => $value";
        $first = false;
      } else {
        $result .= ", $key => $value";
      }
    }
    $result .= "}";
    return $result;
  }
  return "$x" if ($refX eq 'SCALAR');
  return "$x" if ($refX eq 'CODE');
  return $x->as_text() if ($x->can('as_text'));
  return "$x";
}


1;
