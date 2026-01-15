package pm_http_client;
use strict;
use warnings;


our $METHOD_GET = 'GET';
our $METHOD_POST = 'POST';
our $METHOD_PUT = 'PUT';

our $CONTENT_TYPE_JSON = 'application/json';
our $CONTENT_TYPE_OCTET_STREAM = 'application/octet\stream';
our $CONTENT_TYPE_DEFAULT = '';

our $AUTHENTICATION_TYPE_BEARER = 'Bearer';


sub new {
  my ($class, $url) = @_;
  pm_log::debug("Creating http client: url=$url");
  my $self = {
    url => $url,
    headers => {},
    method => 'GET',
    content => undef,
    content_type => $CONTENT_TYPE_JSON,
    binary_content => {}
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


sub file_add {
  my ($self, $field_name, $file_path) = @_;
  $self->{binary_content}->{$field_name} = "\@$file_path";
  $self->{content_type} = $CONTENT_TYPE_DEFAULT;
  return $self;
}


sub binary_content_add {
  my ($self, $field_name, $value) = @_;
  $self->{binary_content}->{$field_name} = "$value";
  $self->{content_type} = $CONTENT_TYPE_DEFAULT;
  return $self;
}


sub as_command {
  my ($self) = @_;
  my $content_type = pm_list->new();
  if ($self->{method} eq $METHOD_POST) {
    if ($self->{content_type} eq $CONTENT_TYPE_JSON) {
      $content_type->push("-H 'Content-type: $self->{content_type}'");
    } elsif ($self->{content_type} eq '') {
      # Use default
    } else {
      die pm_log::exception("Content-type not supported: $self->{content_type}");
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
  my $binary_blocks = pm_list->new();
  while (my ($field, $value) = each %{$self->{binary_content}}) {
    $binary_blocks->push("-F '$field=$value'");
  }
  my $binary_content_as_string = $binary_blocks->join("\\\n  ");
  return <<EOF;
curl \\
  -s \\
  -X $self->{method} '$self->{url}' \\
  ${headers} \\
  $content \\
  $binary_content_as_string
EOF
}


sub send {
  my ($self) = @_;
  my $command = $self->as_command();
  pm_log::debug("Calling curl: $command");
  my $result = `$command`;
  pm_log::debug("Result=$result");
  return pm_json::parse($result);
}


sub get {
  my ($self) = @_;
  $self->method_set($METHOD_GET);
  $self->send();
}


sub post {
  my ($self) = @_;
  $self->method_set($METHOD_POST);
  $self->send();
}


1;

