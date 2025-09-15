use strict;
use warnings;


package pm_table;


# columns: ARRAY or pm_list
# data: ARRAY of ARRAY
sub new {
  pm_log::debug("Creating table");
  my ($class, $columns, $data) = @_;
  die pm_log::exception("data not defined") if (!defined $data);
  die pm_log::exception("data not an array") if (ref($data) ne "ARRAY");
  if (!defined $columns) {
    die pm_log::exception("At least one record is required.") if (scalar @$data == 0);
    $columns = pm_list->new();
    for (my $i = 1; $i <= scalar @{$data->[0]}; $i++) {
      $columns->push("c$i");
    }
  } elsif (ref($columns) eq "ARRAY") {
    $columns = pm_list->new($columns);
  } elsif (ref($columns) eq "pm_list") {
    # Nothing to do
  } else {
    die pm_log::exception("Columns must be arrays or lists.");
  }
  my $self = {
    columns => $columns,
    data => $data
  };
  bless $self, $class;
  return $self;
}


sub filter {
  my ($self, $f_filter) = @_;
  $self->assert_invariant();
  my $record = pm_table_record->new($self->{columns});
  my @data = ();
  foreach my $r (@{$self->{data}}) {
    $record->record_set($r);
    push(@data, $r) if ($f_filter->($record)); 
  }
  return pm_table->new($self->{columns}, \@data);
}


sub first {
  my ($self) = @_;
  $self->assert_invariant();
  if ($self->size() == 0) {
    return undef;
  }
  return $self->get(0);
}


sub get {
  my ($self, $index) = @_;
  $self->assert_invariant();
  my $size = $self->size();
  if ($index >= $size) {
    die pm_log::exception("Index out of bound: index=$index, size=$size");
  }
  return pm_table_record->new($self->{columns}, $self->{data}->[$index]);
}


sub size {
  my ($self) = @_;
  $self->assert_invariant();
  return scalar @{$self->{data}};
}


sub push {
  my ($self, $record) = @_;
  $self->assert_invariant();
  pm_assert::assert_defined($record, "Record can be undef");
  if (ref($record) eq "ARRAY") {
    pm_assert::assert_equals(scalar @$record, $self->{columns}->size(), "Record size is incorrect");
    push(@{$self->{data}}, $record);
  } else {
    pm_assert::assert_equals($record->size(), $self->{columns}->size(), "Record size is incorrect");
    push(@{$self->{data}}, $record->as_array());
  }
}


sub assert_invariant {
  my ($self) = @_;
  pm_assert::assert_defined($self->{columns}, "Null columns");
  pm_assert::assert_defined($self->{data}, "Null data");
  my $size = $self->{columns}->size();
  if ($size > 0) {
    pm_assert::assert_equals($size, scalar @{$self->{data}->[0]}, "Inconsistent size");
  }
}


sub map {
  my ($self, $f) = @_;
  $self->assert_invariant();
  my $result = pm_list->new();
  my $record = pm_table_record->new($self->{columns});
  foreach my $r (@{$self->{data}}) {
    $record->record_set($r);
    $result->push($f->($record)); 
  }
  return $result;
}


sub cell {
  my ($self, $x, $y) = @_;
  $self->assert_invariant();
  pm_assert::assert_true($x < $self->{columns}->size());
  pm_assert::assert_true($y < scalar @{$self->{data}});
  return $self->{data}->[$y]->[$x];
}


sub columns_get {
  my ($self) = @_;
  $self->assert_invariant();
  return $self->{columns};
}


sub width {
  my ($self) = @_;
  $self->assert_invariant();
  return $self->{columns}->size();
}


sub height {
  my ($self) = @_;
  $self->assert_invariant();
  return scalar @{$self->{data}};
}


package pm_table_record;


sub new {
  my ($class, $columns, $record) = @_;
  my $self = {
    columns => $columns,
    record => $record
  };
  bless $self, $class;
  return $self;
}


sub record_set {
  my ($self, $record) = @_;
  pm_assert::assert_equals($self->{columns}->size(), scalar @$record, "Invalid record size");
  $self->{record} = $record;
}


sub get {
  my ($self, $column_name) = @_;
  $self->assert_invariant();
  my $index = $self->{columns}->index_get($column_name);
  $index >= 0 || die pm_log::exception("Invalid column_name: $column_name");
  return $self->{record}->[$index];
}


sub size {
  my ($self) = @_;
  $self->assert_invariant();
  return scalar @{$self->{record}};
}


sub as_hash {
  my ($self) = @_;
  $self->assert_invariant();
  my %hash = ();
  for (my $i = 0; $i < $self->size(); $i++) {
    $hash{$self->{columns}->get($i)} = $self->{record}->[$i];
  }
  return \%hash;
}


sub normalize {
  my ($self) = @_;
  $self->assert_invariant();
  return $self->as_hash();
}


sub assert_invariant {
  my ($self) = @_;
  pm_assert::assert_defined($self->{columns});
  pm_assert::assert_defined($self->{record});
  pm_assert::assert_true($self->{columns}->size(), scalar @{$self->{record}});
}


1;
