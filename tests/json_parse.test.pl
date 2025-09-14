use strict;
use warnings;
use lib 'pm_lib';
use pm_include_test;


my $json_text;
my $json;
$json_text = '{"name":"Masayoshi","skills":["Perl","Bash"],"active":true,"score":42}';
$json = pm_json::parse($json_text);
pm_test_util::assert_equals("Masayoshi", $json->{name}, "name");
pm_test_util::assert_equals(["Perl", "Bash"], $json->{skills}, "skills");
pm_test_util::assert_equals(true, $json->{active}, "active");
pm_test_util::assert_equals(42, $json->{score}, "score");

pm_log::separator();

$json_text = <<EOF;
{
  "name": "Masayoshi",
  "skills": [
    "Perl",
    "Bash"
  ],
  "active": true,
  "score":42
}
EOF
$json = pm_json::parse($json_text);
pm_test_util::assert_equals("Masayoshi", $json->{name}, "name");
pm_test_util::assert_equals(["Perl", "Bash"], $json->{skills}, "skills");
pm_test_util::assert_equals(true, $json->{active}, "active");
pm_test_util::assert_equals(42, $json->{score}, "score");
