use strict;
use warnings;


package pm_table;


# columns: ARRAY or pm_list
# data: ARRAY of ARRAY
sub new {
  pm_log::debug("Creating table");
  my ($class, $columns, $data) = @_;
  defined $data or $data = [];
  die pm_log::exception("data not an array") if (ref($data) ne "ARRAY");
  if (!defined $columns) {
    pm_log::debug("Columns not defined. Generating default columns.");
    $columns = pm_list->new();
    my $A = 65;
    for (my $i = 0; $i < scalar @{$data->[0]}; $i++) {
      $columns->push(chr($A + $i));
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


sub from_data_with_header {
  my ($array_of_array) = @_;
  pm_assert::assert_equals("ARRAY", ref($array_of_array), "Argument must be an array.");
  my $height = @$array_of_array;
  if ($height == 0) {
    return pm_table->new([], $array_of_array);
  }
  my $columns = $array_of_array->[0];
  my @data = ();
  for (my $i = 1; $i < $height; $i++) {
    CORE::push(@data, $array_of_array->[$i]);
  }
  return pm_table->new($columns, \@data);
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


sub where {
  my ($self, $f_filter) = @_;
  return $self->filter($f_filter);
}


sub first {
  my ($self) = @_;
  $self->assert_invariant();
  if ($self->size() == 0) {
    return undef;
  }
  return $self->row_get(0)->as_hash();
}


sub row_get {
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


# Add a record 
sub push {
  my ($self, $record) = @_;
  $self->assert_invariant();
  pm_assert::assert_defined($record, "Record can be undef");
  if (ref($record) eq "ARRAY") {
    pm_assert::assert_equals(scalar @$record, $self->{columns}->size(), "Record size is incorrect");
    push(@{$self->{data}}, $record);
  } elsif (ref($record) eq "pm_list"){
    pm_assert::assert_equals($record->size(), $self->{columns}->size(), "Record size is incorrect");
    push(@{$self->{data}}, $record->as_array());
  } elsif (ref($record) eq "HASH") {
    my @l = ();
    $self->{columns}->for_each(sub {
      my ($column) = @_;
      my $field = $record->{$column};
      pm_assert::assert_defined($field, "field $column cannot be undef.");
      push(@l, $field);
    });
    CORE::push(@{$self->{data}}, \@l);
  } elsif (ref($record) eq "pm_table_record") {
    my @l = ();
    $self->{columns}->for_each(sub {
      my ($column) = @_;
      my $field = $record->get($column);
      pm_assert::assert_defined($field, "field $column cannot be undef.");
      push(@l, $field);
    });
    CORE::push(@{$self->{data}}, \@l);
  } else {
    die pm_log::exception("You can only push a record as an array or a list");
  }
}


sub assert_invariant {
  my ($self) = @_;
  pm_assert::assert_defined($self->{columns}, "Null columns");
  pm_assert::assert_defined($self->{data}, "Null data");
  my $size = $self->{columns}->size();
  my $height = @{$self->{data}};
  if ($size > 0 && $height > 0) {
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


sub as_array_of_hash {
  my ($self) = @_;
  my $columns = $self->columns_get();
  my @lines = ();
  for (my $y = 0; $y < $self->height(); $y++) {
    my %row = ();
    for (my $x = 0; $x < $self->width(); $x++) {
      $row{$columns->get($x)} = $self->cell($x, $y);
    }
    CORE::push(@lines, \%row);
  }
  return \@lines;
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
