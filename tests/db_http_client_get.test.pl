use strict;
use warnings;
use lib 'pm_lib';
use pm_include_test;


# Test get method


my $curl_command = pm_http_client
  ->new("https://www.google.com")
  ->authentication_set("Bearer", "token")
  ->header_add("Content-Type", "application/json")
  ->as_command();
pm_log::info($curl_command);
