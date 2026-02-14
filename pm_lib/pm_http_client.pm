package pm_http_client;
use strict;
use warnings;
use constant {
  true => 1,
  false => 0
};


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
    query_parameters => {},
    method => 'GET',
    content => undef,
    content_schema => undef,
    content_type => $CONTENT_TYPE_JSON,
    binary_content => {},
    output_file => undef
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


sub query_parameter_add {
  my ($self, $key, $value) = @_;
  pm_assert::assert_defined($key);
  return if (!defined $value);
  return if (pm_string::is_empty($value));
  $self->{query_parameters}->{$key} = $value;
  return $self;
}


sub query_parameters_add {
  my ($self, $query_object) = @_;
  foreach my $key (keys %$query_object) {
    my $value = $query_object->{$key};
    $self->query_parameter_add($key, $value);
  }
  return $self;
}


sub content_set {
  my ($self, $content, $content_schema) = @_;
  $self->{content} = $content;
  $self->{content_schema} = $content_schema;
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


sub output_file_set {
  my ($self, $output_file) = @_;
  $self->{output_file} = $output_file;
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
  my $url = $self->{url};
  my $redirection = pm_log::cmd_redirection();
  {
    my $first = true;
    foreach my $key (keys %{$self->{query_parameters}}) {
      if ($first) {
        $url .= "?";
        $first = false;
      } else {
        $url .= "&";
      }
      my $value = $self->{query_parameters}->{$key};
      $url .= "$key=$value";
    }
  }
  my $output_file_params = "";
  if (defined $self->{output_file}) {
    $output_file_params = "-o $self->{output_file}";
  }
  return <<EOF;
curl '$url' \\
  -v \\
  -s \\
  -X $self->{method} \\
  $headers \\
  $content \\
  $output_file_params \\
  $binary_content_as_string \\
  $redirection
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

