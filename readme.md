THE POOR'S MAN LIBRARY
======================

This repository is the library of the poor's man.

- No advanced feature
- No time
- No access to package management systems
- No access to modern language

Yet you still have to get the job done.

The idea is just be able to copy the lib and move forward.
There isn't a lot in the lib and the db is frankly shitty
but you don't always need more. If you are on a linux system
or if git bash is installed, it should work.

HOW TO INSTALL ?
----------------

Just copy the lib at the root of your project or where you see fit.

Then include the lib as below:

```perl
#!/usr/bin/perl

use strict;
use warnings;
use lib 'pm_lib';
use pm_include;
```

LISTS
-----

```perl
pm_list->new([1, 2, 3, 4])
  ->map(sub {$_[0]*10})
  ->filter(sub {$_[0] > 10})
  ->all();
# Returns [20, 30, 40]
```

LOGS
----

```perl
pm_log::debug("Debug message");
pm_log::info("Info message");
pm_log::warning("Warning message");
pm_log::error("Error message");
pm_log::separator();  # Print a line separator
```

COMMAND LINE ARGUMENTS
----------------------

```perl
pm_arguments::flag_definition_set("-v", "VERBOSE");
pm_arguments::flag_definition_set("--verbose", "VERBOSE");
pm_arguments::flag_definition_set("-i", "IGNORE_CASE");
pm_arguments::flag_definition_set("--ignore-case", "IGNORE_CASE");
pm_arguments::option_definition_set("-m", "MAX_COUNT");
pm_arguments::option_definition_set("--max-count", "MAX_COUNT");
pm_arguments::option_definition_set("-n", "LINE_NUMBER");
pm_arguments::option_definition_set("--line-number", "LINE_NUMBER");
pm_arguments::parse("-i", "--max-count", "1", "--verbose", "-n", "2", "pattern", "file");
pm_arguments::flag_get("VERBOSE");  # -> true
pm_arguments::flag_get("IGNORE_CASE");  # -> true
pm_arguments::option_get("MAX_COUNT");  # -> 1
pm_arguments::option_get("LINE_NUMBER");  # -> 2
pm_arguments::positional_argument_size();  # -> 2
pm_arguments::positional_argument_get(0);  # -> 'pattern'
pm_arguments::positional_argument_get(1);  # -> 'file'
```

DATABASE
--------

```perl
my $db_folder = "/path/to/your/db/folder";
my $db = pm_db->new($db_folder);
$db->allocate();  # Create the directory on disk
my $table = $db->create_table("my_table");
$table->insert({x => 0, y => 0});
$table->insert({x => 1, y => 10});
$table->insert({x => 2, y => 20});
$table->insert({x => 3, y => 30});


# Queries

$db->select("my_table")
  ->where(sub {$_[0].x == 2})
  ->first();  # -> {x => 3, y => 30}
$table
  ->where(sub {$_[0].x >= 2})
  ->all();  # -> [{x => 2, y => 20}, {x => 3, y => 30}]


# Update

my $v = $table->first();
$v->{x} = 4;
$v->{y} = 40;
$table->update($v);

# Delete

my $v = $table->first();
$table->delete($v);

# Drop

$table->drop();
$db->delete();
```
