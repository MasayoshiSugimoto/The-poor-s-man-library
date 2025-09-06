package pm_ini;
use strict;
use warnings;


sub ini_file_load {
  my ($path) = @_;
  my %file_as_map = ();
  open my $fh, '<', $path or die pm_log::exception("Can't open file: $!");
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


sub ini_file_write {
  my ($path, $record) = @_;
  open my $fh, '>', $path or die pm_log::exception("Can't open file $path: $!");
  while (my ($key, $value) = each %$record) {
    print $fh "$key=$value\n";
  }
  close $fh;
}


1;

