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


sub chrome_open {
  my ($file_path) = @_;
  system("'/c/Program Files/Google/Chrome/Application/chrome.exe' '$file_path'");
}


sub edge_open {
  my ($file_path) = @_;
  system("'/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe' '$file_path'");
}


sub yank {
  return `cat /dev/clipboard`;
}


1;
