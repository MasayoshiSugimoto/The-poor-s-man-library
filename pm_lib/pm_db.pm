package pm_db;
use strict;
use warnings;


my $_metadata;
my $METADATA_FILE_NAME = "metadata.ini";


sub new {
  my ($class, $path) = @_;
  my $self = {
    path => $path
  };
  bless $self, $class;
  pm_log::debug("Database object created: path=$path");

  # Load database metadata lazily
  my $metadata_path = "$path/$METADATA_FILE_NAME";
  if (!defined $_metadata && -e $metadata_path) {
    pm_log::info("Metadata not defined. Loading metadata file: $metadata_path.");
    $_metadata = pm_db_util::load_ini_file($metadata_path);
  } elsif (!defined $_metadata && !-e $metadata_path) {
    pm_log::info("Metadata not defined. Creating metadata");
    $_metadata = {
      id_counter => 0
    };
  }

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
  defined $_metadata || die "Metadata must be defined before generating ids";
  my $id = $_metadata->{id_counter};
  $_metadata->{id_counter}++;
  pm_db_util::ini_write_file("$self->{path}/$METADATA_FILE_NAME", $_metadata);
  return $id;
}


1;
