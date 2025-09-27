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
#     {
#       rectangle => ["A", "B", "G", "F"],
#       anchor => "menu"
#     }
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
        !defined $vertices{$letter} or die pm_log::exception("Duplicate letter: $letter");
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
  foreach my $letter1 (sort keys %vertices) {
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
    my ($l1, $l2) = @{$segment->{vertices}};
    pm_hash::multi_hash_push(\%segments_by_vertex, $l1, $segment);
    pm_hash::multi_hash_push(\%segments_by_vertex, $l2, $segment);
  }
  # Extract components
  my @components = ();
  foreach my $letter (sort keys %vertices) {
    my $rectangle = component_extract(\%vertices, \@segments, $letter);
    next if (!defined $rectangle);
    my $rectangle_as_text = join "", @$rectangle;
    pm_log::debug("rectangle=$rectangle_as_text");
    push(@components, {
      rectangle => $rectangle,
      anchor => component_extract_anchor(\@matrix, \%vertices, $rectangle)
    });
  }

  return {
    vertices => \%vertices,
    segments => \@segments,
    components => \@components
  };
}


sub component_extract {
  my ($vertices, $segments, $top_left) = @_;
  pm_log::debug("Searching component with left corner: $top_left");

  sub component_from_state {
    my ($state) = @_;
    my @states = ();
    while (defined $state) {
      push(@states, $state);
      $state = $state->{previous};
    }
    my @result = ($states[0]->{letter});
    for (my $i = 1; $i < scalar @states; $i++) {
      if ($states[$i-1]->{direction} ne $states[$i]->{direction}) {
        push(@result, $states[$i]->{letter});
      }
    }
    @result = reverse @result;
    return \@result;
  }

  # Create segment index
  my %segments_by_vertex = ();
  foreach my $segment (@$segments) {
    my ($l1, $l2) = @{$segment->{vertices}};
    pm_hash::multi_hash_push(\%segments_by_vertex, $l1, $segment);
    pm_hash::multi_hash_push(\%segments_by_vertex, $l2, $segment);
  }
  my @queue = ({
    letter => $top_left,
    direction => "",
    previous => undef,
    length => 0
  });
  my $min_length = 9999999999;
  my $component;
  while (scalar @queue > 0) {
    my $state = shift(@queue);
    my $letter1 = $state->{letter};
    my $p1 = $vertices->{$letter1};
    my $direction = $state->{direction};
    foreach my $segment (@{$segments_by_vertex{$letter1}}) {
      my $letter2 = segment_other_get($segment, $letter1);
      my $p2 = $vertices->{$letter2};
      my $new_direction;
      if ($p1->{x} < $p2->{x}) { $new_direction = "right"; }
      elsif ($p1->{y} < $p2->{y}) { $new_direction = "down"; }
      elsif ($p1->{x} > $p2->{x}) { $new_direction = "left"; }
      elsif ($p1->{y} > $p2->{y}) { $new_direction = "up"; }
      pm_log::debug("letter1=$letter1, letter2=$letter2, direction=$direction, new_direction=$new_direction");
      # Acceptable transitions
      next if (!(
        $direction eq $new_direction
        || $direction eq "" && $new_direction eq "right"
        || $direction eq "right" && $new_direction eq "down"
        || $direction eq "down" && $new_direction eq "left"
        || $direction eq "left" && $new_direction eq "up"
      ));
      pm_log::debug("Acceptable transition");
      if ($letter2 eq $top_left) {
        my $c = component_from_state($state);
        my $c_as_text = join("", @$c);
        pm_log::debug("Component found: $c_as_text");
        if ($state->{length} < $min_length) {
          pm_log::debug("Smaller component -> retaining.");
          $min_length = $state->{length};
          $component = $c;
        }
        last;
      }
      my $new_length = $state->{length} + segment_length_get($vertices, $segment);
      pm_log::debug("push: letter=$letter2, direction=$new_direction, length=$new_length");
      push(@queue, {
        letter => $letter2,
        direction => $new_direction,
        previous => $state,
        length => $new_length
      });
    }
  }
  return $component;
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
  my ($letter1, $letter2) = @{$segment->{vertices}};
  my %v1 = %{$vertices->{$letter1}};
  my %v2 = %{$vertices->{$letter2}};
  if ($v1{x} == $v2{x}) {
    return abs($v1{y} - $v2{y});
  } elsif ($v1{y} == $v1{y}) {
    return abs($v1{x} - $v2{x});
  }
}


sub component_extract_anchor {
  my ($matrix, $vertices_ref, $rectangle_ref) = @_;
  my %vertices = %$vertices_ref;
  my @rectangle = @$rectangle_ref;
  my %top_left = %{$vertices{$rectangle[0]}};
  my %top_right = %{$vertices{$rectangle[1]}};
  my %bottom_right = %{$vertices{$rectangle[2]}};
  my %bottom_left = %{$vertices{$rectangle[3]}};
  my $top = $top_left{y};
  my $right = $top_right{x};
  my $bottom = $bottom_left{y};
  my $left = $bottom_left{x};
  my $anchor = "";
  pm_log::debug("top=$top right=$right bottom=$bottom left=$left");
  for (my $y = $top + 1; $y < $bottom; $y++) {
    for (my $x = $left + 1; $x < $right; $x++) {
      my $letter = $matrix->[$y][$x];
      if ($letter =~ /[a-z]/) {
        $anchor .= $letter;
      } elsif (length($anchor) > 0) {
        last;  # We already reached the end of the anchor
      }
    }
  }
  pm_log::debug("anchor=$anchor");
  return $anchor;
}


1;
