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
  if (defined $array) {
    $self = {
      data => $array
    };
  } else {
    $self = {
      data => []
    };
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
  foreach my $x (@{$self->{data}}) {
    $f->($x);
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


sub size {
  my ($self) = @_;
  return scalar @{$self->{data}};
}


sub contains {
  my ($self, $value) = @_;
  foreach my $x (@{$self->{data}}) {
    if ($x == $value) {
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


1;

