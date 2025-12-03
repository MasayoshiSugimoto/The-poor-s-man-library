package pm_os;
use strict;
use warnings;


sub paste {
  return `cat /dev/clipboard`;  # Cygwin only for now.
}


sub user_edit {
  my ($source_file_path) = @_;
  my ($fh, $temp_file) = pm_file::file_temp();
  pm_file::file_copy($source_file_path, $temp_file);
  close $fh;
  system("notepad $temp_file");
  return $temp_file;
}


1;
