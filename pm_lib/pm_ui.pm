use strict;
use warnings;
package pm_ui;
use constant {
  true => 1,
  false => 0
};


sub _buffer_char_write {
  my ($buffer, $char, $x, $y) = @_;
  my $height = @{$buffer};
  die pm_log::exception("Empty buffer") if ($height == 0);
  my $width = @{$buffer->[0]};
  if (!(0 <= $x && $x < $width && 0 <= $y && $y < $height)) {
    die pm_log::exception("Attempt to write outside of the buffer: x=$x y=$y width=$width height=$height");
  }
  $buffer->[$y][$x] = $char;
}


sub _buffer_render {
  my ($buffer) = @_;
  pm_log::debug("Rendering buffer");
  my $height = @{$buffer};
  my $width = @{$buffer->[0]};
  for (my $y = 0; $y < $height; $y++) {
    for (my $x = 0; $x < $width; $x++) {
      print($buffer->[$y]->[$x]);
    }
    # We print new line in debug mode as we expect the buffer to be smaller than the terminal.
    if (defined $pm_constants::CONSOLE_SIZE_DEBUG) {
      print("\n");
    }
  }
}


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


sub _key_normalize  {
  my ($key) = @_;
  my @l = split "", $key;
  return _array_as_key(\@l);
}


sub _array_as_key {
  my ($array) = @_;
  return join("", sort @$array);
}


sub _constraint_pourcentage_get {
  my ($value_as_text) = @_;
  if ($value_as_text =~ /^([0-9]+)%$/) {
    my $pourcentage = $1;
    if (defined $pourcentage && 0 < $pourcentage && $pourcentage <= 100) {
      return $pourcentage;
    }
    die pm_log::exception("Invalid pourcentage: $pourcentage");
  }
}


sub _constraint_ratio_get {
  my ($value_as_text) = @_;
  return _constraint_pourcentage_get($value_as_text) / 100;
}


sub _constraint_unit_get {
  my ($value_as_text) = @_;
  if ($value_as_text =~ /^([0-9]+)$/) {
    my $unit = $1;
    if (defined $unit) {
      return $unit;
    }
    die pm_log::exception("Invalid unit $unit");
  }
}


package pm_component;


sub new {
  my ($class, $layout, $index) = @_;
  pm_log::debug("pm_component->new($index)");
  my $component = $layout->{components}->[$index];
  my $rectangle = $component->{rectangle};
  my $rectangle_as_text = pm_misc::as_text($rectangle);
  pm_assert::assert_equals(4, scalar @$rectangle, "Rectangle must have 4 vertices (found $rectangle_as_text)");
  my $vertex_by_letter = $layout->{vertices};
  my $top = $vertex_by_letter->{$rectangle->[0]}->{y};
  my $right = $vertex_by_letter->{$rectangle->[2]}->{x};
  my $bottom = $vertex_by_letter->{$rectangle->[2]}->{y};
  my $left = $vertex_by_letter->{$rectangle->[0]}->{x};
  my $width = $right - $left;
  my $height = $bottom - $top;
  my $offset = {
    x => $left,
    y => $top
  };
  pm_log::debug("Creating component. width=$width height=$height left=$left top=$top");
  my $self = {
    layout => $layout,
    index => $index,
    width => $width,
    height => $height,
    offset => $offset,
  };
  bless $self, $class;
  return $self;
}


sub string_render {
  my ($self, $string, $line_wrap, $buffer) = @_;
  pm_assert::assert_defined($string, "string not defined");
  pm_assert::assert_defined($buffer, "buffer not defined");
  pm_log::debug("pm_content->string_render($string, $line_wrap)");
  my $width = $self->{width};
  my $height = $self->{height};
  my $offset = $self->{offset};
  my $x = 1;
  my $y = 1;
  foreach my $line (split "\n", $string) {
    foreach my $char (split("", $string)) {
      if ($line_wrap && $x >= $width - 1) {  # New line
        $x = 1;
        $y++;
      }
      if (!$self->is_inside_relative($x, $y)) {
        last;
      }
      my $x_abs = $x + $offset->{x};
      my $y_abs = $y + $offset->{y};
      pm_ui::_buffer_char_write($buffer, $char, $x_abs, $y_abs);
      $x++;
    }
    $y++;
  }
}


sub component_get {
  my ($self) = @_;
  return $self->{layout}->{components}->[$self->{index}];
}


sub anchor_get {
  my ($self) = @_;
  return $self->component_get()->{anchor};
}


sub rectangle_get {
  my ($self) = @_;
  return $self->component_get()->{rectangle};
}


sub is_inside_absolute {
  my ($self, $x, $y) = @_;
  my $offset = $self->{offset};
  $x = $x - $offset->{x};
  $y = $y - $offset->{y};
  return $self->is_inside_relative($x, $y);
}


sub is_inside_relative {
  my ($self, $x, $y) = @_;
  my $offset = $self->{offset};
  return 0 < $x && $x < $self->{width} - 1 && 0 < $y && $y < $self->{height};
}


package pm_layout;

use constant {
  true => 1,
  false => 0
};


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


sub new {
  my ($class, $layout) = @_;
  pm_log::debug("pm_layout->new()");
  my $self = $layout;
  bless $self, $class;
  $self->assert();
  return $self;
}


# This function generates a new layout that solve additional
# contraints given as parameter.
#
# SAMPLE LAYOUT
# =============
#
# A---------------------------B
# |         title             |
# C---------------------------D
# | text                      |
# |                           |
# E---------------------------F
#
# SAMPLE OF CONSTRAINTS
# =====================
#
# constraints = {
#   size => {
#     width => "100%",  # 100% of the terminal size
#     height => "100%"
#   },
#   ABCD => {
#     horizontal_alignment => "center",
#     vertical_alignment => "center",
#     height => 4  # Number of rows (Border included)
#   }
# }
#
sub solve {
  my ($self, $constraints) = @_;
  pm_log::debug("Solving UI constraints");
  my $total_width = $constraints->{size}->{width};
  my $total_height = $constraints->{size}->{height};
  pm_log::debug("total_width=$total_width total_height=$total_height");
  # Normalize constraint for easier access.
  my %normalized_constraints = ();
  foreach my $component (@{$self->{components}}) {
    my $key = pm_ui::_array_as_key($component->{rectangle});
    $normalized_constraints{$key} = {};
  }
  foreach my $key (keys %$constraints) {
    next if ($key eq "size");
    my $constraint = $constraints->{$key};
    $key = pm_ui::_key_normalize($key);
    $normalized_constraints{$key}->{width} = $constraint->{width} if (defined $constraint->{width});
    $normalized_constraints{$key}->{height} = $constraint->{height} if (defined $constraint->{height});
  }
  # Initialize components.
  my %components = ();
  foreach my $component (@{$self->{components}}) {
    my $key = join("", sort @{$component->{rectangle}});
    $components{$key} = $component;
  }
  # Count borders.
  my %horizontal_borders = ();
  my %vertical_borders = ();
  foreach my $vertex (values %{$self->{vertices}}) {
    $horizontal_borders{$vertex->{y}} = true;
    $vertical_borders{$vertex->{x}} = true;
  }
  my $horizontal_borders_count = keys %horizontal_borders;
  my $vertical_borders_count = keys %vertical_borders;
  pm_log::debug("horizontal_borders_count=$horizontal_borders_count vertical_borders_count=$vertical_borders_count");
  # Calculating screen size.
  my $screen_size = pm_console::size_get();
  my $screen_width;
  my $screen_width_constraint = (defined $constraints->{size} && defined $constraints->{size}->{width})
    ? $constraints->{size}->{width}
    : "100%";
  if (pm_ui::_constraint_pourcentage_get($screen_width_constraint)) {
    $screen_width = int(pm_ui::_constraint_ratio_get($screen_width_constraint) * ($screen_size->{x} - $vertical_borders_count));
  } elsif (pm_ui::_constraint_unit_get($screen_width_constraint)) {
    $screen_width = pm_ui::_constraint_unit_get($screen_width_constraint) - $vertical_borders_count;
  } else {
    die pm_log::exception("Invalid screen width constraint: $screen_width_constraint");
  }
  pm_assert::assert_true($screen_width > 0, "Screen width must be greater than 0");
  my $screen_height;
  my $screen_height_constraint = (defined $constraints->{size} && defined $constraints->{size}->{height})
    ? $constraints->{size}->{height}
    : "100%";
  if (pm_ui::_constraint_pourcentage_get($screen_height_constraint)) {
    $screen_height = int(pm_ui::_constraint_ratio_get($screen_height_constraint) * ($screen_size->{y} - $horizontal_borders_count));
  } elsif (pm_ui::_constraint_unit_get($screen_height_constraint)) {
    $screen_height = pm_ui::_constraint_unit_get($screen_height_constraint) - $horizontal_borders_count;
  } else {
    die pm_log::exception("Invalid screen height constraint: $screen_height_constraint");
  }
  pm_assert::assert_true($screen_height > 0, "Screen height must be greater than 0");
  pm_log::debug("Constraint resolved. Screen size: width=$screen_width height=$screen_height");
  pm_log::debug("Resizing components based on constraints");
  my $constraint_max_x = 0;
  my $constraint_max_y = 0;
  foreach my $vertice (values %{$self->{vertices}}) {
    $constraint_max_x = $vertice->{x} if ($constraint_max_x < $vertice->{x});
    $constraint_max_y = $vertice->{y} if ($constraint_max_y < $vertice->{y});
  }
  my %vertices = ();
  my @queue = ();
  foreach my $vertice (values %{$self->{vertices}}) {
    my $x = $vertice->{x};
    my $y = $vertice->{y};
    my $letter = $vertice->{letter};
    if ($x == 0 && $y == 0) {
      $vertices{$letter} = $vertice;
      push(@queue, $vertice);
    } elsif ($x == 0 && $y == $constraint_max_y) {
      $vertices{$letter} = {
        letter => $vertice->{letter},
        x => 0,
        y => $screen_size->{y} - 1
      };
      push(@queue, $vertice);
    } elsif ($x == $constraint_max_x && $y == 0) {
      $vertices{$letter} = {
        letter => $vertice->{letter},
        x => $screen_size->{x} - 1,
        y => 0
      };
      push(@queue, $vertice);
    } elsif ($x == $constraint_max_x && $y == $constraint_max_y) {
      $vertices{$letter} = {
        letter => $vertice->{letter},
        x => $screen_size->{x} - 1,
        y => $screen_size->{y} - 1
      };
      push(@queue, $vertice);
    } else {
      $vertices{$letter} = {
        letter => $letter
      };
    }
  }
  # Solve constraints starting from vertex connected to already resolved vertices.
  while (scalar @queue > 0) {
    my $v0 = shift @queue;
    foreach my $segment (@{$self->{segments}}) {
      next if (
        $segment->{vertices}->[0] ne $v0->{letter}
        && $segment->{vertices}->[1] ne $v0->{letter}
      );
      my $other_letter = segment_other_get($segment, $v0->{letter});
      my $v1 = $self->{vertices}->{$other_letter};
      pm_log::debug("l0=$v0->{letter} l1=$v1->{letter}");
      # Check if already solved
      if (defined $vertices{$other_letter}->{x} && defined $vertices{$other_letter}->{y}) {
        pm_log::debug("Already resolved");
        next;
      }
      foreach my $normalized_rectangle (keys %normalized_constraints) {
        next if (!($normalized_rectangle =~ /$segment->{vertices}->[0]/));
        next if (!($normalized_rectangle =~ /$segment->{vertices}->[1]/));
        pm_log::debug("rectange=$normalized_rectangle");
        my $constraint = $normalized_constraints{$normalized_rectangle};
        if ($v0->{x} == $v1->{x} && $v0->{y} < $v1->{y}) {
          pm_log::debug("v0.y < v1.y");
          if (defined $vertices{$other_letter}->{y}) {
            # Do nothing
          } elsif (!defined $constraint || !defined $constraint->{height}) {
            pm_log::debug("No height constraint. Same as layout");
            $vertices{$other_letter}->{y} = $vertices{$v0->{letter}}->{y} + ($v1->{y} - $v0->{y});
          } elsif (pm_ui::_constraint_pourcentage_get($constraint->{height})) {
            pm_log::debug("Height pourcentage constraint: $constraint->{height}");
            $vertices{$other_letter}->{y} = $vertices{$v0->{letter}}->{y} + pm_ui::_constraint_ratio_get($constraint->{height}) * $screen_height;
          } elsif (pm_ui::_constraint_unit_get($constraint->{height})) {
            pm_log::debug("Height unit constraint: $constraint->{height}");
            $vertices{$other_letter}->{y} = $vertices{$v0->{letter}}->{y} + pm_ui::_constraint_unit_get($constraint->{height}) - 1;
          }
          $vertices{$other_letter}->{x} = $vertices{$v0->{letter}}->{x};
        } elsif ($v0->{y} == $v1->{y} && $v0->{x} < $v1->{x}) {
          pm_log::debug("v0.x < v1.x");
          if (defined $vertices{$other_letter}->{x}) {
            # Do nothing
          } elsif (!defined $constraint || !defined $constraint->{width}) {
            pm_log::debug("No width constraint. Same as layout");
            $vertices{$other_letter}->{x} = $vertices{$v0->{letter}}->{x} + ($v1->{x} - $v0->{x});
          } elsif (!defined $constraint) {
            die pm_log::exception("v0 should be already solved");
          } elsif (pm_ui::_constraint_pourcentage_get($constraint->{width})) {
            pm_log::debug("Width pourcentage constraint: $constraint->{width}");
            $vertices{$other_letter}->{x} = $vertices{$v0->{letter}}->{x} + pm_ui::_constraint_ratio_get($constraint->{width}) * $screen_width;
          } elsif (pm_ui::_constraint_unit_get($constraint->{width})) {
            pm_log::debug("Width unit constraint: $constraint->{width}");
            $vertices{$other_letter}->{x} = $vertices{$v0->{letter}}->{x} + pm_ui::_constraint_unit_get($constraint->{width}) - 1;
          }
          $vertices{$other_letter}->{y} = $vertices{$v0->{letter}}->{y};
        }
        if (defined $vertices{$other_letter}->{x} && defined $vertices{$other_letter}->{y}) {
          my $v = $vertices{$other_letter};
          pm_log::debug("Vertex solved: letter=$v->{letter} x=$v->{x} y=$v->{y}");
          push(@queue, $v1);
        }
      }
    }
  }
  return pm_layout->new({
    vertices => \%vertices,
    segments => $self->{segments},
    components => $self->{components}
  });
}


sub size_get {
  my ($self) = @_;
  my %vertices = %{$self->{vertices}};
  my $size = {x => 0, y => 0};
  foreach my $vertex (values %vertices) {
    $size->{x} = $vertex->{x} if ($size->{x} < $vertex->{x});
    $size->{y} = $vertex->{y} if ($size->{y} < $vertex->{y});
  }
  $size->{x}++;
  $size->{y}++;
  return $size;
}


sub segments_by_vertex_get {
  my ($self) = @_;
  my %segments_by_vertex = ();
  foreach my $segment (@{$self->{segments}}) {
    my ($l1, $l2) = @{$segment->{vertices}};
    pm_hash::multi_hash_push(\%segments_by_vertex, $l1, $segment);
    pm_hash::multi_hash_push(\%segments_by_vertex, $l2, $segment);
  }
  return \%segments_by_vertex;
}


sub from_string {
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
      } elsif (!defined $border && $letter2 =~ /[A-Z]/) {
        pm_assert::assert_fail("There must be at least one border between vertices.");
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
      } elsif (!defined $border && $letter2 =~ /[A-Z]/) {
        pm_assert::assert_fail("There must be at least one border between vertices.");
      } elsif (defined $border && $letter2 =~ /[A-Z]/) {
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
    my $rectangle_as_text = pm_ui::_array_as_key($rectangle);
    pm_assert::assert_true(scalar @$rectangle == 4, "Rectangle must have 4 vertices. Found $rectangle_as_text");
    pm_log::debug("rectangle=$rectangle_as_text");
    push(@components, {
      rectangle => $rectangle,
      anchor => _component_extract_anchor(\@matrix, \%vertices, $rectangle)
    });
  }

  return pm_layout->new({
    vertices => \%vertices,
    segments => \@segments,
    components => \@components
  });
}


sub layout_constraint_solve {
  my ($layout_blue_print) = @_;
  pm_log::debug("Solve layout constraints.");
}


sub assert {
  my ($self) = @_;
  my $size = $self->size_get();
  my $virtual_screen = _virtual_screen_create($self);
  # Vertices cannot be next to each other.
  foreach my $vertex (values %{$self->{vertices}}) {
    pm_assert::assert_equals($size->{y}, scalar @$virtual_screen, "Virtual screen has invalid y size");
    pm_assert::assert_equals($size->{x}, scalar @{$virtual_screen->[0]}, "Virtual screen has invalid x size");
    $virtual_screen->[$vertex->{y}]->[$vertex->{x}] = $vertex->{letter};
  }
  foreach my $vertex (values %{$self->{vertices}}) {
    my @offsets = (
      {x => 0, y => -1},
      {x => 1, y => 0},
      {x => 0, y => 1},
      {x => -1, y => 0},
    );
    foreach my $offset (@offsets) {
      my $x = $vertex->{x} + $offset->{x};
      my $y = $vertex->{y} + $offset->{y};
      next if ($x < 0 || $x >= $size->{x});
      next if ($y < 0 || $y >= $size->{y});
      my $letter = $virtual_screen->[$y]->[$x];
      pm_assert::assert_true(
        $letter eq " " || $letter eq "-" || $letter eq "|" || $letter eq ".",
        "Vertices cannot be next to each others."
      );
    }
  }
}


sub render {
  my ($self, $content) = @_;
  pm_log::debug("pm_layout->render()");
  my $layout = $self;
  my $content_as_text = pm_misc::as_text($content);
  pm_log::debug("content=$content_as_text");
  my $terminal_size = pm_console::size_get();
  my $width = $terminal_size->{x};
  my $height = $terminal_size->{y};
  pm_log::debug("Terminal size: width=$width height=$height");
  # Creating screen buffer
  my @buffer = ();
  for (my $y = 0; $y < $height; $y++) {
    my @row = ();
    for (my $x = 0; $x < $width; $x++) {
      push(@row, " ");
    }
    push(@buffer, \@row);
  }
  # Rendering components in order
  for (my $i = 0; $i < scalar @{$layout->{components}}; $i++) {
    my $component = pm_component->new($layout, $i);
    my $anchor = $component->anchor_get();
    pm_log::debug("anchor=$anchor");
    if (defined $anchor && exists $content->{$anchor}) {
      pm_log::debug("Rendering component: anchor=$anchor");
      $component->string_render($content->{$anchor}, false, \@buffer);
    }
  }
  # Rendering borders
  pm_log::debug("Rendering borders");
  my $vertice_by_letter = $layout->{vertices};
  foreach my $segment (@{$layout->{segments}}) {
    my $vertices = $segment->{vertices};
    my $p1 = $vertice_by_letter->{$vertices->[0]};
    my $p2 = $vertice_by_letter->{$vertices->[1]};
    if ($segment->{border} eq "-") {
      my $start;
      my $end;
      my $y = $p1->{y};
      if ($p1->{x} < $p2->{x}) {
        $start = $p1->{x};
        $end = $p2->{x};
      } else {
        $start = $p2->{x};
        $end = $p1->{x};
      }
      for (my $x = $start + 1; $x < $end; $x++) {
        pm_ui::_buffer_char_write(\@buffer, "─", $x, $y);
      }
    } elsif ($segment->{border} eq "|") {
      my $start;
      my $end;
      my $x = $p1->{x};
      if ($p1->{y} < $p2->{y}) {
        $start = $p1->{y};
        $end = $p2->{y};
      } else {
        $start = $p2->{y};
        $end = $p1->{y};
      }
      for (my $y = $start + 1; $y < $end; $y++) {
        pm_ui::_buffer_char_write(\@buffer, "│", $x, $y);
      }
    } elsif ($segment->{border} eq ".") {
      # Do nothing
    } else {
      die pm_log::exception("Invalid border: border=$segment->{border}");
    }
  }
  # Rendering corner
  pm_log::debug("Rendering corners");
  my $segments_by_vertex = $self->segments_by_vertex_get();
  foreach my $letter1 (sort keys %{$layout->{vertices}}) {
    my $v1 = $layout->{vertices}->{$letter1};
    defined $v1 or die pm_log::exception("V1 should be defined");
    my $segments = $segments_by_vertex->{$letter1};
    my $up = false;
    my $right = false;
    my $down = false;
    my $left = false;
    foreach my $segment (@$segments) {
      next if ($segment->{border} eq ".");
      my $letter2 = segment_other_get($segment, $letter1);
      my $v2 = $layout->{vertices}->{$letter2};
      defined $v2 or die pm_log::exception("V2 should be defined");
      if ($v1->{x} == $v2->{x} && $v1->{y} < $v2->{y}) {
        $down = true;
      } elsif ($v1->{x} == $v2->{x} && $v1->{y} > $v2->{y}) {
        $up = true;
      } elsif ($v1->{y} == $v2->{y} && $v1->{x} < $v2->{x}) {
        $right = true;
      } elsif ($v1->{y} == $v2->{y} && $v1->{x} > $v2->{x}) {
        $left = true;
      } else {
        #die pm_log::exception("Vertex should be aligned");
      }
    }
    my $corner = " ";
    if ($up && $right && $down && $left) {
      $corner = "┼";
    } elsif ($up && $right && $left) {
      $corner = "┴";
    } elsif ($up && $left && $down) {
      $corner = "┤";
    } elsif ($up && $right && $down) {
      $corner = "├";
    } elsif ($right && $down && $left) {
      $corner = "┬";
    } elsif ($up && $right) {
      $corner = "└";
    } elsif ($right && $down) {
      $corner = "┌";
    } elsif ($down && $left) {
      $corner = "┐";
    } elsif ($left && $up) {
      $corner = "┘";
    } elsif ($up && $down) {
      $corner = "│";
    } elsif ($left && $right) {
      $corner = "─";
    } else {
      die pm_log::exception("Unexpected condition");
    }
    pm_ui::_buffer_char_write(\@buffer, $corner, $v1->{x}, $v1->{y});
  }
  pm_ui::_buffer_render(\@buffer);
}


sub component_has {
  my ($self, $component_key) = @_;
  foreach my $component (@{$self->{components}}) {
    return true if (pm_ui::_array_as_key($component->{rectangle}) eq $component_key);
  }
  return false;
}


sub component_extract {
  my ($vertices, $segments, $top_left_letter) = @_;
  pm_log::debug("Searching component with left corner: $top_left_letter");

  sub _component_from_state {
    my ($state) = @_;
    pm_log::debug("_component_from_state()");
    my @states = ();
    while (defined $state) {
      push(@states, $state);
      $state = $state->{previous};
    }
    my $states_length = @states;
    my @result = ();
    for (my $i = 0; $i < $states_length; $i++) {
      my $previous = ($i+$states_length-1) % $states_length;
      pm_log::debug("previous=$previous");
      my $d = $states[$i]->{direction};
      my $letter = $states[$i]->{letter};
      pm_log::debug("letter=$letter direction=$d");
      if ($states[$i]->{direction} ne $states[$previous]->{direction}) {
        pm_log::debug("Pushing: $letter");
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
    letter => $top_left_letter,
    direction => "up",
    previous => undef,
    length => 0
  });
  my $top_left = $vertices->{$top_left_letter};
  my $min_length = 9999999999;
  my $component;
  my %visited = ();
  while (scalar @queue > 0) {
    my $state = shift(@queue);
    my $letter1 = $state->{letter};
    my $p1 = $vertices->{$letter1};
    my $direction = $state->{direction};
    foreach my $segment (@{$segments_by_vertex{$letter1}}) {
      my $letter2 = segment_other_get($segment, $letter1);
      next if ($visited{$letter2});
      my $p2 = $vertices->{$letter2};
      my $new_direction;
      if ($p1->{x} < $p2->{x}) { $new_direction = "right"; }
      elsif ($p1->{y} < $p2->{y}) { $new_direction = "down"; }
      elsif ($p1->{x} > $p2->{x}) { $new_direction = "left"; }
      elsif ($p1->{y} > $p2->{y}) { $new_direction = "up"; }
      else { pm_assert::fail("Direction must be up, right, down or left."); }
      pm_log::debug("letter1=$letter1, letter2=$letter2, direction=$direction, new_direction=$new_direction");
      next if ($p2->{x} < $top_left->{x} || $p2->{y} < $top_left->{y});
      # Acceptable transitions
      next if (!(
        $direction eq $new_direction
        || $direction eq "up" && $new_direction eq "right"
        || $direction eq "right" && $new_direction eq "down"
        || $direction eq "down" && $new_direction eq "left"
        || $direction eq "left" && $new_direction eq "up"
      ));
      pm_log::debug("Acceptable transition");
      if ($letter2 eq $top_left_letter) {
        my $c = _component_from_state($state);
        my $c_as_text = join("", @$c);
        pm_assert::assert_true(scalar @$c == 4, "Component must have 4 vertices. Found $c_as_text");
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
      $visited{$letter2} = true;
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


sub _component_extract_anchor {
  my ($matrix, $vertices_ref, $rectangle_ref) = @_;
  pm_log::debug("pm_layout::_component_extract_anchor()");
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
      if ($letter =~ /[a-z0-9]/) {
        $anchor .= $letter;
      } elsif (length($anchor) > 0) {
        last;  # We already reached the end of the anchor
      }
    }
  }
  pm_log::debug("anchor=$anchor");
  return $anchor;
}


sub _virtual_screen_create {
  my ($layout) = @_;
  my $size = $layout->size_get();
  my @virtual_screen = ();
  for (my $y = 0; $y < $size->{y}; $y++) {
    my @row = ();
    for (my $x = 0; $x < $size->{x}; $x++) {
      push @row, " ";
    }
    push @virtual_screen, \@row;
  }
  return \@virtual_screen;
}


sub _constraint_size_normalize {
  my ($self, $component_size) = @_;
  pm_log::debug("pm_ui::_constraint_normalize_size()");
  my $width = exists $component_size->{width}
    ? $component_size->{width}
    : "100%";
  my $height = exists $component_size->{height}
    ? $component_size->{height}
    : "100%";
  my $screen_size = pm_console::size_get();
  my $border_count = $self->_border_count();
  if (pm_ui::_constraint_pourcentage_get($width)) {
    $width = int(pm_ui::_constraint_ratio_get($width) * ($screen_size->{x} - $border_count->{vertical}));
  } elsif (pm_ui::_constraint_unit_get($width)) {
    $width = pm_ui::_constraint_unit_get($width);
  } else {
    die pm_log::exception("Invalid screen width constraint: $width");
  }
  if (pm_ui::_constraint_pourcentage_get($height)) {
    $height = int(pm_ui::_constraint_ratio_get($height) * ($screen_size->{x} - $border_count->{horizontal}));
  } elsif (pm_ui::_constraint_unit_get($height)) {
    $height = pm_ui::_constraint_unit_get($height);
  } else {
    die pm_log::exception("Invalid screen height constraint: $height");
  }
  return {
    width => $width,
    height => $height
  };
}


# Normalize constraints for easier processing later.
sub _constraint_normalize {
  my ($self, $constraints) = @_;
  pm_log::debug("pm_layout->_constraint_normalize()");
  my %normalized_constraints = ();
  if (!exists $constraints->{size}) {
    $normalized_constraints{size} = "100%";  # Default screen size is size of terminal.
  }
  $normalized_constraints{size} = $self->_constraint_size_normalize($constraints->{size});
  # Normalize component key
  foreach my $key (keys %{$constraints}) {
    next if ($key eq "size");
    my $component_constraint = $constraints->{$key};
    my $normalized_component_constraint = $self->_constraint_size_normalize($component_constraint);
    my $normalized_key = pm_ui::_key_normalize($key);
    $normalized_constraints{$normalized_key} = $normalized_component_constraint;
    pm_assert::assert_true($self->component_has($normalized_key), "Component does not have key: $normalized_key");
  }
  return \%normalized_constraints;
}


sub _border_count {
  my ($self) = @_;
  pm_log::debug("pm_layout->_border_count()");
  my %horizontal_borders = ();
  my %vertical_borders = ();
  foreach my $vertex (values %{$self->{vertices}}) {
    $horizontal_borders{$vertex->{y}} = true;
    $vertical_borders{$vertex->{x}} = true;
  }
  my %border_counts = ();
  $border_counts{horizontal} = keys %horizontal_borders;
  $border_counts{vertical} = keys %vertical_borders;
  return \%border_counts;
}


1;
