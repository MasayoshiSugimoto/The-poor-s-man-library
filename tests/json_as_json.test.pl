use strict;
use warnings;
use lib 'pm_lib';
use pm_include_test;
use constant {
  true => 1,
  false => 0
};


# Test conversion to json.


pm_log::debug("Undef");
pm_test_util::assert_equals('null', pm_json::as_json(undef), "Undef");
pm_log::debug("Empty object");
pm_test_util::assert_equals('{}', pm_json::as_json({}), "Empty object");
pm_log::debug("Hash with 1 number property");
pm_test_util::assert_equals('{"x":0}', pm_json::as_json({x=>0}), "Hash with 1 number property");
pm_log::debug("Hash with multiple number properties");
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
pm_test_util::assert_equals(
  '{"o":{"a":"000"}}',
  pm_json::as_json({o => {a => "000"}}, {o => {a => "string"}}),
  "Schema with string"
);
pm_test_util::assert_equals(
  '{"o":{"a":0}}',
  pm_json::as_json({o => {a => "000"}}, {o => {a => "number"}}),
  "Schema with number"
);
pm_test_util::assert_equals(
  '{"o":{"a":true}}',
  pm_json::as_json({o => {a => true}}, {o => {a => "boolean"}}),
  "Schema with true"
);
pm_test_util::assert_equals(
  '{"o":{"a":false}}',
  pm_json::as_json({o => {a => false}}, {o => {a => "boolean"}}),
  "Schema with false"
);
