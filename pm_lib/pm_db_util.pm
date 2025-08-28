package pm_db_util;


use File::Path qw(remove_tree);


sub load_ini_file {
  my ($path) = @_;
  my %file_as_map = ();
  open my $fh, '<', $path or die "Can't open file: $!";
  while (my $line = <$fh>) {
    $line = pm_string::without_new_line($line);
    if ($line =~ /([^=]+)=(.*)/) {
      my $key = $1;
      my $value = $2;
      chomp($key);
      chomp($value);
      $file_as_map{$key} = $value;
    }
  }
  close $fh;
  return \%file_as_map;
}


sub ini_write_file {
  my ($path, $record) = @_;
  open my $fh, '>', $path or die "Can't open file $path: $!";
  while (my ($key, $value) = each %$record) {
    print $fh "$key=$value\n";
  }
  close $fh;
}


sub query_log {
  my ($text) = @_;
  pm_log::debug("QUERY|$text");
}


sub directory_delete {
  my ($directory) = @_;
  my $err;
  remove_tree($directory, {safe => true, error => \$err});
  if ($err) {
    for my $diag (@$err) {
      while (my ($file, $message) = each %$diag) {
        pm_log::warning("Problem removing $file: $message");
      }
    }
  }
}


1;
