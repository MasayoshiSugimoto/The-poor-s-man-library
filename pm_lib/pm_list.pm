package pm_list;
use strict;
use warnings;


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


sub as_array {
  my ($self) = @_;
  return $self->{data};
}


1;

