package pm_http_client;
use strict;
use warnings;


our $METHOD_GET = 'GET';
our $METHOD_POST = 'POST';
our $METHOD_PUT = 'PUT';


sub new {
  my ($class, $url) = @_;
  pm_log::debug("Creating http client: url=$url");
  my $self = {
    url => $url,
    headers => {},
    method => 'GET'
  };
  bless $self, $class;
  return $self;
}


sub header_add {
  my ($self, $key, $value) = @_;
  $self->{headers}->{$key} = $value;
  return $self;
}


sub authentication_set {
  my ($self, $authentication_type, $token) = @_;
  $self->header_add("Authorization", "$authentication_type $token");
  return $self;
}


sub as_command {
  my ($self) = @_;
  my $headers = pm_list::of_hash($self->{headers})
    ->map(sub {"-H '$_[0]->{key}: $_[0]->{value}'"})
    ->join("\\\n  ");
  return <<EOF;
curl \\
  -X $self->{method} \\
  ${headers} \\
  '$self->{url}'
EOF
}


sub send {
  my ($self) = @_;
  my $command = $self->as_command();
  pm_log::info("Calling curl: $command");
  system($command);
}


1;

