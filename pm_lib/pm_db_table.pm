package pm_db_table;
use strict;
use warnings;
use constant {
  true => 1,
  false => 0
};


sub new {
  pm_log::debug("Creating db table object");
  my ($class, $database, $table_name, $columns) = @_;
  pm_assert::assert_defined($database, "database");
  pm_assert::assert_defined($table_name, "table_name");
  pm_assert::assert_defined($columns, "columns");
  if (!pm_list->new($columns)->contains($pm_constants::DB_TABLE_PRIMARY_KEY_FIELD)) {
    push(@$columns, $pm_constants::DB_TABLE_PRIMARY_KEY_FIELD);
  }
  my $self = {
    database => $database,
    table_name => $table_name,
    table => undef
  };
  bless $self, $class;
  if (!defined $self->{table}) {
    $self->load();
  }
  if (!defined $self->{table}) {
    $self->{table} = pm_table->new($columns, []);
  }
  pm_log::debug("Table created: $table_name");
  return $self;
}


sub load {
  my ($self) = @_;
  pm_log::debug("Loading data from disk.");
  my $directory = $self->path_get();
  my $first = true;
  my $table;
  foreach my $file (glob("$directory/*")) {
    my $record = pm_ini::ini_file_load($file);
    if ($first) {
      my @columns = sort keys %$record;
      $table = pm_table->new(\@columns, []);
      $first = false;
    }
    $table->push($record);
  }
  $self->{table} = $table;
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
  return $self->{table}->filter(sub {$f_filter->($_[0])});
}


sub as_table {
  my ($self) = @_;
  return $self->{table};
}


sub insert {
  my ($self, $record) = @_;
  pm_db_util::query_log("INSERT INTO $self->{table_name}");
  $self->assert_table_exist_on_disk();
  !exists $record->{$pm_constants::DB_TABLE_PRIMARY_KEY_FIELD}
    or die pm_log::exception("Attempt to insert a record which already exist");
  my $id = $self->{database}->id_generate();
  $record->{$pm_constants::DB_TABLE_PRIMARY_KEY_FIELD} = $id;
  $self->{table}->push($record);
  pm_ini::ini_file_write($self->record_path_get($id), $record);
}


sub update {
  my ($self, $record) = @_;
  pm_db_util::query_log("UPDATE $self->{table_name}");
  $self->assert_table_exist_on_disk();
  my $id = $record->{$pm_constants::DB_TABLE_PRIMARY_KEY_FIELD};
  defined $id
    or die pm_log::exception("Attempt to update a record which does not exist");
  $self->{table}->push($record);
  pm_ini::ini_file_write($self->record_path_get($id), $record);
}


sub upsert {
  my ($self, $record) = @_;
  pm_db_util::query_log("UPSERT INTO $self->{table_name}");
  $self->assert_table_exist_on_disk();
  my $id = $record->{$pm_constants::DB_TABLE_PRIMARY_KEY_FIELD};
  if (!defined $id) {
    $id = $self->{database}->id_generate();
    $record->{$pm_constants::DB_TABLE_PRIMARY_KEY_FIELD} = $id;
  }
  $self->{table}->push($record);
  pm_ini::ini_file_write($self->record_path_get($id), $record);
}


sub delete {
  my ($self, $record) = @_;
  pm_db_util::query_log("DELETE $self->{table_name}");
  $self->assert_table_exist_on_disk();
  my $id = $record->{$pm_constants::DB_TABLE_PRIMARY_KEY_FIELD};
  defined $id or die pm_log::exception("Attempt to delete a record which does not has a primary key");
  $self->{table} = $self->{table}
    ->filter(sub {$_[0]->{$pm_constants::DB_TABLE_PRIMARY_KEY_FIELD} != $id});
  pm_file::file_delete($self->record_path_get($id));
}


sub assert_table_exist_on_disk {
  my ($self) = @_;
  if (!-d $self->path_get()) {
    die pm_log::exception("Table does not exist: $self->path_get()");
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


sub size {
  my ($self) = @_;
  return $self->{table}->size();
}


1;
