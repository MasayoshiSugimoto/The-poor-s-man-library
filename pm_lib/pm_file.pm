package pm_file;
use strict;
use warnings;


sub file_delete {
  my ($file_path) = @_;
  pm_log::debug("Deleting file: $file_path");
  unlink($file_path) or die "Could not delete file $file_path: $!";
  pm_log::info("File deleted: $file_path");
}


1;
