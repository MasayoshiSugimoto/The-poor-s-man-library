package pm_db_table;
use strict;
use warnings;


sub new {
  my ($class, $database, $table_name, $data) = @_;
  my $self = {
    database => $database,
    table_name => $table_name,
    columns => [],
    data => $data
  };
  bless $self, $class;
  if (! defined $data) {
    pm_log::debug("Data not provisioned. Loading data from disk.");
    my @l = ();
    my $directory = $self->path_get();
    foreach my $file (glob("$directory/*")) {
      push(@l, pm_db_util::load_ini_file($file));
    }
    $self->{data} = \@l;
  }
  pm_log::debug("Table created: $table_name");
  return $self;
}


sub drop {
  my ($self) = @_;
  my $path = $self->path_get();
  pm_log::info("Droping table: table_name=$self->{table_name} path=$path");
  pm_db_util::directory_delete($path);
}


sub where {
  my ($self, $f_filter) = @_;
  pm_db_util::query_log("WHERE ...");
  my @data = ();
  foreach my $record (@{$self->{data}}) {
    if ($f_filter->($record)) {
      pm_log::debug("Pushing record: $record");
      push(@data, $record);
    }
  }
  return pm_db_table->new($self->{database}, $self->{table_name}, \@data);
}


sub first {
  my ($self) = @_;
  pm_db_util::query_log("FIRST");
  return $self->{data}[0];
}


sub all {
  my ($self) = @_;
  pm_db_util::query_log("ALL");
  return $self->{data};
}


sub insert {
  my ($self, $record) = @_;
  pm_db_util::query_log("INSERT INTO $self->{table_name}");
  $self->assert_table_exist_on_disk();
  my $id;
  if (exists $record->{$pm_constants::DB_TABLE_PRIMARY_KEY_FIELD}) {
    $id = $record->{$pm_constants::DB_TABLE_PRIMARY_KEY_FIELD};
  } else {
    $id = $self->{database}->id_generate();
    $record->{$pm_constants::DB_TABLE_PRIMARY_KEY_FIELD} = $id;
  }
  push(@{$self->{data}}, $record);
  pm_db_util::ini_write_file($self->record_path_get($id), $record);
}


sub update {
  my ($self, $record) = @_;
  pm_db_util::query_log("UPDATE $self->{table_name}");
  $self->assert_table_exist_on_disk();
  my $id;
  exists $record->{$pm_constants::DB_TABLE_PRIMARY_KEY_FIELD}
    || die "Attempt to update a record which does not exist";
  $id = $record->{$pm_constants::DB_TABLE_PRIMARY_KEY_FIELD};
  push(@{$self->{data}}, $record);
  pm_db_util::ini_write_file($self->record_path_get($id), $record);
}


sub set_columns {
  my ($self, $columns) = @_;
  pm_log::debug("Setting columns of table: $self->{table_name}");
}


sub assert_table_exist_on_disk {
  my ($self) = @_;
  if (!-d $self->path_get()) {
    die "Table does not exist: $self->path_get()";
  }
}


sub path_get {
  my ($self) = @_;
  return "$self->{database}->{path}/$self->{table_name}";
}


sub record_path_get {
  my ($self, $id) = @_;
  my $dir = $self->path_get();
  return "$dir/$id.ini";
}


1;
