use strict;
use warnings;
use constant {
  true => 1,
  false => 0
};
package pm_hash;


sub get_or_default {
  my ($hash, $key, $default) = @_;
  my $value = $hash->{$key};
  if (defined $value) {
    return $value;
  } else {
    return $default;
  }
}


sub multi_hash_push {
  my ($hash, $key, $value) = @_;
  my $values = $hash->{$key};
  if (defined $values) {
    push(@$values, $value);
  } else {
    $hash->{$key} = [$value];
  }
}


1;
