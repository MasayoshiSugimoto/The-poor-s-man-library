package pm_list;
use strict;
use warnings;
use constant {
  true => 1,
  false => 0
};


sub new {
  my ($class, $array) = @_;
  my $self;
  if (!defined $array) {
    $self = {
      data => []
    };
  } elsif (ref($array) eq "ARRAY") {
    $self = {
      data => $array
    };
  } elsif (ref($array) eq "pm_list") {
    $self = {
      data => $array->as_array()
    };
  } else {
    my $ref = ref($array);
    die pm_log::exception("Invalid data type: $array");
  }
  bless $self, $class;
  return $self;
}


sub map {
  my ($self, $f) = @_;
  my @result = ();
  foreach my $x (@{$self->{data}}) {
    push(@result, $f->($x));
  }
  return pm_list->new(\@result);
}


sub filter {
  my ($self, $f) = @_;
  my @result = ();
  foreach my $x (@{$self->{data}}) {
    if ($f->($x)) {
      push(@result, $x);
    }
  }
  return pm_list->new(\@result);
}


sub for_each {
  my ($self, $f) = @_;
  my @result = ();
  for (my $i = 0; $i < scalar @{$self->{data}}; $i++) {
    $f->($self->{data}->[$i], $i);
  }
}


sub as_array {
  my ($self) = @_;
  return $self->{data};
}


sub get {
  my ($self, $index) = @_;
  return $self->{data}[$index];
}


sub push {
  my ($self, $value) = @_;
  push(@{$self->{data}}, $value);
  return $self;
}


sub concat {
  my ($self, $list) = @_;
  my $result = pm_list->new();
  $self->for_each(sub {$result->push($_[0])});
  $list->for_each(sub {$result->push($_[0])});
  return $result;
}


sub size {
  my ($self) = @_;
  return scalar @{$self->{data}};
}


sub contains {
  my ($self, $value) = @_;
  foreach my $x (@{$self->{data}}) {
    if (pm_misc::equals($x, $value)) {
      return true;
    }
  }
  return false;
}


sub join {
  my ($self, $separator) = @_;
  return pm_string::join($self->{data}, $separator);
}


sub of_hash {
  my ($hash) = @_;
  my $result = pm_list->new();
  while (my ($key, $value) = each %{$hash}) {
    $result->push({key => $key, value => $value});
  }
  return $result;
}


sub index_get {
  my ($self, $value) = @_;
  for (my $i = 0; $i < $self->size(); $i++) {
    if ("$self->{data}->[$i]" eq "$value") {
      return $i;
    }
  }
  return -1;
}


sub equals {
  my ($self, $list) = @_;
  if ($self->size() != $list->size()) {
    return false;
  }
  for (my $i = 0; $i < $self->size(); $i++) {
    if ($self->get($i) ne $list->get($i)) {
      return false;
    }
  }
  return true;
}


sub normalize {
  my ($self) = @_;
  return $self->as_array();
}


sub as_text {
  my ($self, $indent) = @_;
  return pm_misc::as_text($self->{data}, $indent);
}


1;

