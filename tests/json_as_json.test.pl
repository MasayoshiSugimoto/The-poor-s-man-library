use strict;
use warnings;
use lib 'pm_lib';
use pm_include_test;


# Test conversion to json.


pm_test_util::assert_equals('', pm_json::as_json(undef), "Undef");
pm_test_util::assert_equals('{}', pm_json::as_json({}), "Empty object");
pm_test_util::assert_equals('{"x":0}', pm_json::as_json({x=>0}), "Hash with 1 number property");
pm_test_util::assert_equals(
  '{"x":0,"y":1}', 
  pm_json::as_json({x=>0, y=>1}),
  "Hash with multiple number properties"
);
pm_test_util::assert_equals(
  '{"a":"x"}', 
  pm_json::as_json({a=>"x"}),
  "Hash with one string property"
);
pm_test_util::assert_equals(
  '{"a":"x","b":"y"}', 
  pm_json::as_json({a=>"x", b=>"y"}),
  "Hash with multiple string properties"
);
pm_test_util::assert_equals(
  '{"a":"x","b":1}', 
  pm_json::as_json({a=>"x", b=>1}),
  "Hash with multiple types"
);
pm_test_util::assert_equals(
  '{"a":"x","b":1,"c":{"z":2}}', 
  pm_json::as_json({a=>"x", b=>1, c=>{z=>2}}),
  "Nested hash"
);
