package pm_db_util;


use File::Path qw(remove_tree);


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
