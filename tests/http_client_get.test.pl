use strict;
use warnings;
use lib 'pm_lib';
use pm_include_test;


# Test get method


my $curl_command = pm_http_client
  ->new("https://www.example.com")
  ->authentication_set("Bearer", "token")
  ->header_add("Content-Type", "application/json")
  ->as_command();
pm_log::info($curl_command);

$curl_command = pm_http_client
  ->new("https://www.example.com")
  ->authentication_set("Bearer", "token")
  ->method_set("POST")
  ->content_set({a => 0, b => "x"})
  ->as_command();
pm_log::info($curl_command);
