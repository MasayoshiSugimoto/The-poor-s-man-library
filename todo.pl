#!/usr/bin/perl

use strict;
use warnings;
use lib '.';
use lib 'pm_lib';
use Data::Dumper;
use pm_include;
use constant {
  true => 1,
  false => 0
};


my $WORKING_DIRECTORY = "$ENV{HOME}/.todo";
my $DB_DIRECTORY = "$WORKING_DIRECTORY/db";
my $DB = undef;  # Handle to the database
my $DB_TABLE_NAME_TASK = "task";

pm_log::debug("PRINTING APPLICATION CONTEXT");
pm_log::debug("============================");
pm_log::debug();
pm_log::debug("WORKING_DIRECTORY=$WORKING_DIRECTORY");
pm_log::debug("DB_DIRECTORY=$DB_DIRECTORY");
pm_log::debug();

if (mkdir $WORKING_DIRECTORY) {
  pm_log::info("Working directory created: $WORKING_DIRECTORY");
}

$DB = pm_db->new($DB_DIRECTORY);
if (!$DB->is_allocated()) {
  $DB->allocate();
  $DB->create_table($DB_TABLE_NAME_TASK, ["task", "status"]);
}

pm_arguments::parse(@ARGV);

my $size = pm_console::size_get();
pm_log::debug("width=$size->{x}, height=$size->{y}");

my $command = pm_arguments::positional_argument_get(0);
defined $command or die pm_log::exception("You need to specify a command.");
if ($command eq "new") {
  my $task = pm_arguments::positional_argument_get(1);
  defined $task or die pm_log::exception("You must specify a task.");
  pm_log::info("Creating new task: $task");
  $DB->from($DB_TABLE_NAME_TASK)
    ->insert({task => $task, status => false});
} elsif ($command eq "list") {
  pm_log::debug("Listing all tasks");
  my $tasks = $DB->from($DB_TABLE_NAME_TASK)
    ->as_table()
    ->select(["status", "task"]);
  print(pm_md::table_as_markdown($tasks));
  print("");
} elsif ($command eq "done") {
  my $task_name = pm_arguments::positional_argument_get(1);
  defined $task_name or die pm_log::exception("You must specify a task.");
  pm_log::info("Marking task as done: $task_name");
  my $task = $DB->from($DB_TABLE_NAME_TASK)
    ->where(sub {$_[0]->get("task") eq $task_name})
    ->first();
  $task->{status} = true;
  $DB->from($DB_TABLE_NAME_TASK)
    ->update($task);
} else {
  my $list = pm_list->new(["a", "b", "c"]);
  pm_ui::render_list_selection($list, 2);
  pm_log::fatal("You need to specify a command.");
}
