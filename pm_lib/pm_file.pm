package pm_file;
use strict;
use warnings;
use File::Path qw(remove_tree);
use File::Temp qw(tempfile);


sub file_delete {
  my ($file_path) = @_;
  pm_log::info("Deleting file: $file_path");
  unlink($file_path) or die pm_log::exception("Could not delete file $file_path: $!");
  pm_log::info("File deleted: $file_path");
}


sub file_safe_delete {
  my ($file_path) = @_;
  pm_log::info("Deleting file: $file_path");
  if (-e $file_path) {
    eval {
      unlink($file_path) 
        or die pm_log::exception("Could not delete file $file_path: $!");
      pm_log::info("File deleted: $file_path");
    }
  } else {
    pm_log::debug("File does not exist. Skipping. file_path=$file_path");
  }
}


sub file_load_as_string {
  my ($file_path) = @_;
  pm_log::debug("Loading file: $file_path");
  my $result = "";
  open my $fh, '<', $file_path or die pm_log::exception("Can't open file $file_path: $!");
  while (my $line = <$fh>) {
    $result .= $line;
  }
  close $fh;
  return $result;
}


sub file_save_string {
  my ($file_path, $content) = @_;
  pm_log::debug("Saving file: file_path=$file_path, content=$content");
  open my $fh, '>', $file_path or die pm_log::exception("Can't open file $file_path $!");
  print $fh $content;
  close $fh;
  pm_log::debug("File saved: file_path=$file_path");
}


sub file_copy {
  my ($src_file_path, $output_file_path) = @_;
  my $content = file_load_as_string($src_file_path);
  file_save_string($output_file_path, $content);
}


sub file_temp {
  return tempfile();
}


sub directory_delete {
  my ($folder) = @_;
  pm_log::debug("Deleting folder: $folder");
  remove_tree($folder) or warn "Could not delete $folder: $!";
}


1;
