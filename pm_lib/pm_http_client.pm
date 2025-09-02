package pm_http_client;
use strict;
use warnings;


our $METHOD_GET = 'GET';
our $METHOD_POST = 'POST';
our $METHOD_PUT = 'PUT';

our $CONTENT_TYPE_JSON = 'application/json';


sub new {
  my ($class, $url) = @_;
  pm_log::debug("Creating http client: url=$url");
  my $self = {
    url => $url,
    headers => {},
    method => 'GET',
    content => undef,
    content_type => $CONTENT_TYPE_JSON
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


sub method_set {
  my ($self, $method) = @_;
  $self->{method} = $method;
  return $self;
}


sub content_set {
  my ($self, $content) = @_;
  $self->{content} = $content;
  return $self;
}


sub as_command {
  my ($self) = @_;
  my $content_type = pm_list->new();
  if ($self->{method} eq $METHOD_POST) {
    if ($self->{content_type} eq $CONTENT_TYPE_JSON) {
      $content_type->push("-H 'Content-type: $self->{content_type}'");
    } else {
      die "Content-type not supported: $self->{content_type}";
    }
  }
  my $headers = pm_list::of_hash($self->{headers})
    ->map(sub {"-H '$_[0]->{key}: $_[0]->{value}'"})
    ->concat($content_type)
    ->join("\\\n  ");
  my $content = "";
  if (defined $self->{content}) {
    if ($self->{content_type} eq $CONTENT_TYPE_JSON) {
      $content = pm_json::as_json($self->{content});
      $content = "-d '$content'";
    }
  }
  return <<EOF;
curl \\
  -X $self->{method} \\
  ${headers} \\
  $content \\
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

