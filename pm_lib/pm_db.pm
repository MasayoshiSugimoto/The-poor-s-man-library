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
    $_metadata = pm_ini::ini_file_load($metadata_path);
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
  my ($self, $table_name, $columns) = @_;
  pm_log::debug("Creating table: $table_name");
  pm_assert::assert_defined($table_name, "table_name");
  pm_assert::assert_defined($columns, "columns");
  my $path = $self->table_path_get($table_name);
  if (-d $path) {
    pm_log::debug("Table already exist. Skipping creation.");
  } else {
    mkdir $path;
    pm_log::info("Table created at $path");
  }
  if (!grep {$_ eq $pm_constants::DB_TABLE_PRIMARY_KEY_FIELD} @$columns) {
    push(@$columns, $pm_constants::DB_TABLE_PRIMARY_KEY_FIELD);
  }
  my $table = pm_db_table->new($self, $table_name, $columns);
}


sub from {
  my ($self, $table_name) = @_;
  pm_db_util::query_log("FROM $table_name");
  my $path = $self->table_path_get($table_name);
  # TODO: Replace by some metadata
  opendir(my $dh, $path) or die "table does not exist: $path $!";
  my @files = grep { -f "$path/$_" } readdir($dh);
  my @columns = ();
  if (scalar @files > 0) {
    my $sample = pm_ini::ini_file_load("$path/$files[0]");
    foreach my $key (sort keys %$sample) {
      push(@columns, $key);
    }
  }
  closedir($dh);
  return pm_db_table->new($self, $table_name, \@columns);
}


sub table_path_get {
  my ($self, $table_name) = @_;
  return "$self->{path}/$table_name";
}


sub id_generate {
  my ($self) = @_;
  pm_log::debug("Generating database id");
  defined $_metadata
    or die pm_log::exception("Metadata must be defined before generating ids");
  my $id = $_metadata->{id_counter};
  $_metadata->{id_counter}++;
  pm_ini::ini_file_write("$self->{path}/$METADATA_FILE_NAME", $_metadata);
  return $id;
}


sub is_allocated {
  my ($self) = @_;
  return -d $self->{path};
}


1;
