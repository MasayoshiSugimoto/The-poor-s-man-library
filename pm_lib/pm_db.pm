package pm_db;
use strict;
use warnings;


sub new {
  my ($class, $path) = @_;
  my $self = {
    path => $path
  };
  bless $self, $class;
  pm_log::debug("Database object created: path=$path");
  return $self;
}


sub allocate {
  my ($self) = @_;
  if (-d $self->{path}) {
    pm_log::debug("Database already exist at $self->{path}. Skipping allocation.");
  } else {
    pm_log::info("Creating database at: $self->{path}");
    mkdir $self->{path};
  }
}


sub delete {
  my ($self) = @_;
  if (-d $self->{path}) {
    pm_log::info("Deleting database: $self->{path}");
    pm_db_util::remove_tree($self->{path}, {error => \my $err});
    pm_db_util::directory_delete($self->{path});
  } else {
    pm_log::info("Database does not exist on disk. Skipping deletion.");
  }
}


sub create_table {
  my ($self, $table_name) = @_;
  pm_log::debug("Creating table: $table_name");
  my $path = $self->table_path_get($table_name);
  if (-d $path) {
    pm_log::debug("Table already exist. Skipping creation.");
  } else {
    mkdir $path;
    pm_log::info("Table created at $path");
  }
  my $table = pm_db_table->new($self, $table_name);
}


sub select {
  my ($self, $table_name) = @_;
  pm_db_util::query_log("SELECT $table_name");
  my $path = $self->table_path_get($table_name);
  if (!-d $path) {
    die "Table does not exist: $path"
  }
  return pm_db_table->new($self, $table_name);
}


sub table_path_get {
  my ($self, $table_name) = @_;
  return "$self->{path}/$table_name";
}


sub id_generate {
  my ($self) = @_;
  pm_log::debug("Generating database id");
  my $path = "$self->{path}/metadata.ini";
  my $metadata = {};
  if (-e $path) {
    pm_log::debug("Loading metadata file: $path");
    $metadata = pm_db_util::load_ini_file($path);
  } else {
    pm_log::debug("Creating metadata file: $path");
    $metadata = {
      id_counter => 0
    };
  }
  my $id = $metadata->{id_counter};
  $metadata->{id_counter}++;
  pm_db_util::ini_write_file($path, $metadata);
  return $id;
}


1;
