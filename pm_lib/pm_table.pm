use strict;
use warnings;


package pm_table;


sub new {
  pm_log::debug("Creating table");
  my ($class, $columns, $data) = @_;
  pm_assert::assert_defined($columns);  # Array or List
  pm_assert::assert_defined($data);  # Array of Array
  if (ref($columns) eq "ARRAY") {
    $columns = pm_list->new($columns);
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
  if ($self->size() == 0) {
    return undef;
  }
  return $self->get(0);
}


sub get {
  my ($self, $index) = @_;
  my $size = $self->size();
  if ($index >= $size) {
    die "Index out of bound: index=$index, size=$size";
  }
  my %record = ();
  for (my $i = 0; $i < $self->{columns}->size(); $i++) {
    $record{$self->{columns}->get($i)} = $self->{data}->[$index]->[$i];
  }
  return \%record;
}


sub size {
  my ($self) = @_;
  return scalar @{$self->{data}};
}


sub push {
  my ($self, $record) = @_;
  pm_assert::assert_defined($record, "Record can be undef");
  if (ref($record) eq "ARRAY") {
    pm_assert::assert_equals(scalar @$record, $self->{columns}->size(), "Record size is incorrect");
    push(@{$self->{data}}, $record);
  } else {
    pm_assert::assert_equals($record->size(), $self->{columns}->size(), "Record size is incorrect");
    push(@{$self->{data}}, $record->as_array());
  }
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
  $self->{record} = $record;
}


sub get {
  my ($self, $column_name) = @_;
  my $index = $self->{columns}->index_get($column_name);
  $index >= 0 || die "Invalid column_name: $column_name";
  return $self->{record}->[$index];
}


1;
