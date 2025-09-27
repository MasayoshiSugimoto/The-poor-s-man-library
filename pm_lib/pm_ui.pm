use strict;
use warnings;
package pm_ui;
use constant {
  true => 1,
  false => 0
};


sub render_list_selection {
  my ($list, $selected) = @_;
  $selected = 0 if !defined $selected;
  $list->for_each(sub {
    my ($item, $index) = @_;
    if ($index == $selected) {
      print "> $item\n";
    } else {
      print "  $pm_color::GREY$item$pm_color::RESET\n";
    }
  });
}

# Sample spec for a UI definition language.
#
# A---------------------------B
# |         title             |
# C---------------------------D
# | text                      |
# |                           |
# E---------------------------F
#
# constraints = {
#   size => {
#     width => "100u",
#     height => "100u"
#   },
#   ABCD => {
#     vertical_alignment => "center",
#     size => {
#       height: 3  # Number of rows (Without borders)
#     }
#   },
#   CDEF => {
#     overflow => false
#   }
# }
#
# Another example:
#
# A--------B------------------C
# | menu   | title            |
# |        D..................E
# |        | content          |
# |        |                  |
# F--------G------------------H
#
# Data structure:
# layout_blue_print = {
#   vertices => {
#     A => {
#       letter => "A",
#       x => 0,
#       y => 0
#     }
#   },
#   segments => [
#     {
#       vertices => ["A", "B"],
#       border => "-"
#     }
#   ],
#   components => [
#     ["A", "B", "G", "F"]
#   ]
# }

sub layout_parse {
  my ($layout_as_string) = @_;
  my @lines = split("\n", $layout_as_string, -1);
  my $width;
  my $height = 0;
  my @matrix = ();
  for (my $i = 0; $i < scalar @lines; $i++) {
    my $line = pm_string::as_linux_string(pm_string::trim($lines[$i]));
    next if (length($line) == 0);
    # Validate width
    if (!defined $width) {
      $width = length($line);
    } else {
      $width == length($line) or die pm_log::exception("Inconsistent length");
    }
    my @line_as_array = split("", $line);
    push(@matrix, \@line_as_array);
    $height++;
  }
  pm_log::debug("matrix size:{width=$width, height=$height}");
  # Extract vertices
  my %vertices = ();
  for (my $y = 0; $y < $height; $y++) {
    for (my $x = 0; $x < $width; $x++) {
      my $letter = $matrix[$y][$x];
      if ($letter =~ /[A-Z]/) {
        pm_log::debug("vertice:{letter=$letter, x=$x, y=$y}");
        $vertices{$letter} = {
          letter => $letter,
          x => $x,
          y => $y
        };
      }
    }
  }
  # Extract segments
  my @segments = ();
  foreach my $letter1 (keys %vertices) {
    my %vertice = %{$vertices{$letter1}};
    my $border;
    for (my $x = $vertice{x} + 1; $x < $width; $x++) {
      my $letter2 = $matrix[$vertice{y}][$x];
      if (!defined $border && $letter2 eq ".") {
        $border = ".";
      } elsif (!defined $border && $letter2 eq "-") {
        $border = "-";
      } elsif ($letter2 =~ /[A-Z]/) {
        pm_log::debug("segment:{vertices=[$letter1, $letter2], border=$border}");
        push(@segments, {
          vertices => [$letter1, $letter2],
          border => $border
        });
        last;
      } elsif (defined $border && $border ne $letter2) {
        die pm_log::exception("Inconsistent border");
      } elsif (defined $border && $border eq $letter2) {
        # Do nothing
      } else {
        last;
      }
    }
    $border = undef;
    for (my $y = $vertice{y} + 1; $y < $height; $y++) {
      my $letter2 = $matrix[$y][$vertice{x}];
      if (!defined $border && $letter2 eq ".") {
        $border = ".";
      } elsif (!defined $border && $letter2 eq "|") {
        $border = "|";
      } elsif ($letter2 =~ /[A-Z]/) {
        pm_log::debug("segment:{vertices=[$letter1, $letter2], border=$border}");
        push(@segments, {
          vertices => [$letter1, $letter2],
          border => $border
        });
        last;
      } elsif (defined $border && $border ne $letter2) {
        die pm_log::exception("Inconsistent border: border=$border, letter2=$letter2");
      } elsif (defined $border && $border eq $letter2) {
        # Do nothing
      } else {
        last;
      }
    }
  }
  # Create segment index
  my %segments_by_vertex = ();
  foreach my $segment (@segments) {
    my ($l1, $l2) = $segment->{vertices};
    pm_hash::multi_hash_push(\%segments_by_vertex, $l1, $segment);
    pm_hash::multi_hash_push(\%segments_by_vertex, $l2, $segment);
  }
  # Extract components
  my @queue = ();
  foreach my $letter1 (keys %vertices) {
    my $vertice = $vertices{$letter1};
  }
}


sub component_extract {
  my ($vertices, $segments, $vertex_letter) = @_;
  # Create segment index
  my %segments_by_vertex = ();
  foreach my $segment (@$segments) {
    my ($l1, $l2) = $segment->{vertices};
    pm_hash::multi_hash_push(\%segments_by_vertex, $l1, $segment);
    pm_hash::multi_hash_push(\%segments_by_vertex, $l2, $segment);
  }
  my @queue = ({
    letter => $vertex_letter,
    direction => "",
    previous => undef
    length => 0
  });
  my @path = ();
  my %visited = ();
  while (scalar @queue > 0) {
    my $state = shift(@queue);
    my $letter1 = $state->{letter};
    my $direction = $state->{direction};
    foreach my $segment (@{$segments_by_vertex{$letter}}) {
      my $letter2 = segment_other_get($segment, $letter1);
      pm_log::debug("letter2=$letter2");
      my $p1 = $vertices->{$letter1};
      my $p2 = $vertices->{$letter2};
      my $new_direction;
      if ($p1->{x} < $p2->{x}) {
        $new_direction = "right";
      } elsif ($p1->{y} > $p2->{y}) {
        $new_direction = "down";
      } elsif ($p1->{x} > $p2->{x}) {
        $new_direction = "left";
      } elsif ($p1->{y} < $ps->{y}) {
        $new_direction = "up";
      }
      # Acceptable transitions
      next if (!(
        $direction eq $new_direction
        || $direction eq "" && $new_direction eq "right"
        || $direction eq "right" && $new_direction eq "down"
        || $direction eq "down" && $new_direction eq "left"
        || $direction eq "left" && $new_direction eq "up"
      ));
      if ($letter2 == $vertex_letter) {
        pm_log::debug("Component found");
        last;
      }
      my $new_length = $state->{length} + segment_length_get($vertices, $segment);
      next if ($new_length >= $visited{$letter2});
      $visited{$letter2} = $new_length;
      pm_log::debug("push: letter1=$letter1, letter2=$letter2, direction=$new_direction");
      push(@queue, {
        letter => $letter2,
        direction => $new_direction,
        previous => $letter1
      });
    }
  }
}


sub segment_other_get {
  my ($segment, $vertex_letter) = @_;
  my @vertices = @{$segment->{vertices}};
  if ($vertices[0] eq $vertex_letter) {
    return $vertices[1];
  } elsif ($vertices[1] eq $vertex_letter) {
    return $vertices[0];
  } else {
    die pm_log::exception("Invalid vertex_letter: segments=[$vertices[0],$vertices[1]] vertex_letter=$vertex_letter");
  }
}


sub segment_length_get {
  my ($vertices, $segment) = @_;
  my ($letter1, $letter2) = $segment->{vertices};
  my %v1 = %{$vertices->{$letter1}};
  my %v2 = %{$vertices->{$letter2}};
  if ($v1{x} == $v2{x}) {
    return abs($v1{y} - $v2{y});
  } elsif ($v1{y} == $v1{y}) {
    return abs($v1{x} - $v2{x});
  }
}


1;
