use strict;
use warnings;
package pm_misc;
use constant {
  true => 1,
  false => 0
};


sub equals {
  my ($a, $b) = @_;

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


1;
