use strict;
use warnings;
use lib 'pm_lib';
use pm_include_test;


pm_test_util::assert_true(pm_misc::equals(undef, undef), "undef=undef");
pm_test_util::assert_true(pm_misc::equals(0, 0), "0=0");
pm_test_util::assert_true(pm_misc::equals(1, 1), "1=1");
pm_test_util::assert_true(pm_misc::equals(1.0, 1), "1.0=1");
pm_test_util::assert_true(pm_misc::equals(1, 1.0), "1=1.0");
pm_test_util::assert_true(pm_misc::equals(1.0, 1.0), "1.0=1.0");
pm_test_util::assert_true(pm_misc::equals(1.23, 1.23), "1.23=1.23");
pm_test_util::assert_true(pm_misc::equals("0", "0"), "0=0");
pm_test_util::assert_true(pm_misc::equals("1", "1"), "1=1");
pm_test_util::assert_true(pm_misc::equals("", ""), "=");
pm_test_util::assert_true(pm_misc::equals("hello", "hello"), "hello=hello");
pm_test_util::assert_true(pm_misc::equals([], []), "[]=[]");
pm_test_util::assert_true(pm_misc::equals([1], [1]), "[1]=[1]");
pm_test_util::assert_true(pm_misc::equals([1,2,3], [1,2,3]), "[1,2,3]=[1,2,3]");
pm_test_util::assert_true(pm_misc::equals(["hello", "world"], ["hello", "world"]), "[hello, world]=[hello, world]");
pm_test_util::assert_true(pm_misc::equals({}, {}), "{}={}");
pm_test_util::assert_true(pm_misc::equals({a=>1}, {a=>1}), "{a=>1}={a=>1}");
pm_test_util::assert_true(pm_misc::equals({a=>1, b=>2}, {a=>1, b=>2}), "{a=>1, b=>2}={a=>1, b=>2}");
pm_test_util::assert_true(pm_misc::equals({a=>"hello"}, {a=>"hello"}), "{a=>hello}={a=>hello}");
pm_test_util::assert_true(pm_misc::equals({a=>"hello", b=>"world"}, {a=>"hello", b=>"world"}), "{a=>hello, b=>world}={a=>hello, b=>world}");
pm_test_util::assert_true(pm_misc::equals({a=>1, b=>"world"}, {a=>1, b=>"world"}), "{a=>1, b=>world}={a=>1, b=>world}");


pm_test_util::assert_false(pm_misc::equals(undef, 0), "undef=0");
pm_test_util::assert_false(pm_misc::equals(0, undef), "0=undef");
pm_test_util::assert_false(pm_misc::equals(undef, 1), "undef=1");
pm_test_util::assert_false(pm_misc::equals(1, undef), "1=undef");
pm_test_util::assert_false(pm_misc::equals(0, 1), "0=1");
pm_test_util::assert_false(pm_misc::equals(1, 0), "1=0");
pm_test_util::assert_false(pm_misc::equals(1.23, 1.0), "1.23=1.0");
pm_test_util::assert_false(pm_misc::equals(1.0, 1.23), "1.0=1.23");
pm_test_util::assert_false(pm_misc::equals("1", "0"), "1=0");
pm_test_util::assert_false(pm_misc::equals("0", "1"), "0=1");
pm_test_util::assert_false(pm_misc::equals("1", ""), "1=");
pm_test_util::assert_false(pm_misc::equals("", "1"), "=1");
pm_test_util::assert_false(pm_misc::equals("hello", "world"), "hello=world");
pm_test_util::assert_false(pm_misc::equals([1], []), "[1]=[]");
pm_test_util::assert_false(pm_misc::equals([], [1]), "[]=[1]");
pm_test_util::assert_false(pm_misc::equals([1,2,3], [1,2,4]), "[1,2,3]=[1,2,4]");
pm_test_util::assert_false(pm_misc::equals(["hello", "world"], ["x", "world"]), "[hello, world]=[x, world]");
pm_test_util::assert_false(pm_misc::equals({a=>1}, {}), "{a=>1}={}");
pm_test_util::assert_false(pm_misc::equals({}, {a=>1}), "{}={a=>1}");
pm_test_util::assert_false(pm_misc::equals({a=>1, b=>"world"}, {a=>1, b=>"x"}), "{a=>1, b=>world}={a=>1, b=>x}");
