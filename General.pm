# just some general routines for throwing around and manipulating
# files and directories.
# $Id: General.pm,v 1.4 2003-07-18 07:15:23 thanatos Exp $

package General;

use strict;
use Error;

  # exluding "." and ".." entries.
sub slurp_files {
  my $self = shift;
  my ($dir) = @_;

  if(!$dir) {
    new Error->throw("General->slurp_files() wassn't passed a directory!\n");
  }
    # get our main directory entries
  opendir DIRS, $dir or new Error->throw("General->slurp_files() couldn't "
    . "open $dir\n");
    # turn that into an array
  my @dirs;
  while(my $sub_dir = readdir(DIRS)) {
    if($sub_dir ne "." && $sub_dir ne "..") {
      push @dirs, $dir ."/" . $sub_dir;
    }
  }
  closedir DIRS;

   # and return them happily.
  return @dirs;
}

  # get the file extension
sub get_ext {
  my $self = shift;
  my ($file) = @_;
  $file =~ s/\n//g;
  my @elts = split(/\./, $file);
  return pop @elts;
}

	# method returns a mysql datetime formatted string based on the
	# current system time.
sub nowMysqlDateTime {
	my $self = shift;
}

	# return a number parsed in a human readable format
sub parseHuman {
	my $self = shift;
	my $number = shift;

	my @digits = split(//, $number);
	my $humanized;

		# create an index value
	my $index = 0;
		# iterate over digits, build new string.	
	my $num_digits = $#digits;	
	while($index <= $num_digits) {
		my $delim;
		if((($index + 1)) % 3 == 0 && $index != ($num_digits)) {
			$delim = ',';
		}
		my $digi = pop @digits;
		$humanized = $delim . $digi . $humanized;
		$index++;
	}
	return $humanized;
}

  # exluding "." and ".." entries.
sub slurp_files_date_sorted_inverse {
  my $self = shift;
  my ($dir) = @_;

    # get our main directory entries
  opendir DIRS, $dir or new Error->throw("General->slurp_files_date_sorted()" .
    " Couldn't open $dir\n"); 
    # turn that into an array
  my @dirs;
  while(my $sub_dir = readdir(DIRS)) {
    if($sub_dir ne "thumbnails") {
      push @dirs, $dir . "/" . $sub_dir;
    }
  }
  closedir DIRS;


    # pop off . and ..
  shift @dirs;
  shift @dirs;

  my @sort_array;
  foreach my $entry (@dirs) {
    my @file_data = stat $entry;
    my $mod_sec = $file_data[9];
    push @sort_array, "$entry:$mod_sec";
  }

  my @new_dirs;
  foreach my $item (sort {$a cmp $b} @sort_array) {
    my ($entry, $time) = split(/:/, $item);
    push @new_dirs, $entry;
  }

  return @new_dirs;
}

  # exluding "." and ".." entries.
sub slurp_files_date_sorted {
  my $self = shift;
  my ($dir) = @_;

    # get our main directory entries
  opendir DIRS, $dir or new Error->throw("General->slurp_files_date_sorted()" .
    " Couldn't open $dir\n"); 
    # turn that into an array
  my @dirs;
  while(my $sub_dir = readdir(DIRS)) {
    if($sub_dir ne "thumbnails") {
      push @dirs, $dir . "/" . $sub_dir;
    }
  }
  closedir DIRS;


    # pop off . and ..
  shift @dirs;
  shift @dirs;

  my @sort_array;
  foreach my $entry (@dirs) {
    my @file_data = stat $entry;
    my $mod_sec = $file_data[9];
    push @sort_array, "$entry:$mod_sec";
  }

  my @new_dirs;
  foreach my $item (sort {$b cmp $a} @sort_array) {
    my ($entry, $time) = split(/:/, $item);
    push @new_dirs, $entry;
  }

  return @new_dirs;
}


sub slurp_archived_files {
  my $self = shift;
  my ($dir) = @_;

  if(!$dir) {
    new Error->("General->slurp_archived_files() is missing an argument!\n");
  }
  my $proper_name = $self->get_last($dir); 

    # get our main directory entries
  opendir DIRS, $dir or new Error->throw("General->slurp_archived_files() " .
    " : Couldn't open $dir\n");
    # turn that into an array
  my @dirs;
  while(my $sub_dir = readdir(DIRS)) {
    if($sub_dir ne "thumbnails") {
      if($self->get_last($sub_dir) =~ /^$proper_name\d\d\d\d\./) {
        push @dirs, $dir ."/" . $sub_dir;
      }
    }
  }
  closedir DIRS;

   # and return them happily.
  return @dirs;
}

sub slurp_unarchived_files {
  my $self = shift;
  my ($dir) = @_;

    my $proper_name = $self->get_last($dir);

    # get our main directory entries
  opendir DIRS, $dir or new Error->throw("General->slurp_unarchived_files() " .
    "Couldn't open $dir\n");
    # turn that into an array
  my @dirs;
  while(my $sub_dir = readdir(DIRS)) {
    if($sub_dir ne "thumbnails") {
      if($self->get_last($sub_dir) !~ /^$proper_name\d\d\d\d\./) {
        push @dirs, $dir ."/" . $sub_dir;
      }
    }
  }
  closedir DIRS;

    # pop off . and ..
  shift @dirs; shift @dirs;
   # and return them happily.
  return @dirs;
}

# routine that pops the filename off the end of a fully
# qualified path.
sub get_last {
  my $self = shift;
  my $full_path = shift;

  my @elts = split(/\//, $full_path);
  return pop @elts;
}

sub get_ext {
  my $self = shift;
  my $full_path = shift;

  my @elts = split(/\./, $full_path);
  return pop @elts;
}

  # lowercase all the files in a passed directory
sub lowercase_dir {
  my $self = shift;
  my ($dir) = @_;

  my @files = $self->slurp_files($dir);

  foreach my $file (@files) {
    if($file =~ /[A-Z]/) {
      my $new_name = lc $file;
      my $rc;
      if(! -f $new_name) { 
        $rc = link $file, $new_name;
        if(!$rc) {
          new Error->throw("Couldn't link $file to $new_name, reason : $!\n");
        }
      }
      $rc = unlink $file;
      if(!$rc) {
        new Error->throw("Couldn't unlink $file, reason : $!\n");
      }
    }
  }
}

  # lowercase all the files in a passed directory
sub remove_parens {
  my $self = shift;
  my ($dir) = @_;

  my @files = $self->slurp_files($dir);
   
  foreach my $file (@files) {
    if($file =~ /\(/ || $file =~ /\)/) {
      my $new_name = $file;
      $new_name =~ s/\(|\)//g;
      link $file, $new_name; 
      unlink $file;
    }
  }
}


  # this routine removes grabs non jpeg files from a directory.
sub slurp_non_jpgs {
  my $self = shift;
  my ($dir) = @_;

    # get our main directory entries
  opendir DIRS, $dir or new Error->throw("General->slurp_non_jpgs() " .
    " Couldn't open $dir\n");
    # turn that into an array
  my @dirs;
  while(my $subdir = readdir(DIRS)) {
    if($subdir !~ /\.jpg$/ && $subdir ne "thumbnails") {
      push @dirs, "$dir/$subdir";
    }
  }
  closedir DIRS;

    # pop off . and ..
  shift @dirs;
  shift @dirs;

  return @dirs;
}

sub slurp_non_images {
  my $self = shift;
  my ($dir) = @_;
    
    # get our main directory entries
  opendir DIRS, $dir or new Error->throw("General->slurp_non_jpgs() " .
    " Couldn't open $dir\n");
    # turn that into an array
  my @dirs;
  while(my $subdir = readdir(DIRS)) {
    if($subdir !~ /\.jpg$/ && $subdir !~ /\.gif$/ && $subdir ne 'thumbnails') {
      push @dirs, "$dir/$subdir";
    }
  }
  closedir DIRS;

    # pop off . and ..
  shift @dirs;
  shift @dirs;

  return @dirs;
}

  # this routine builds an array of all the filenames that
  # do  appear to be jpgs from a directory.
sub slurp_jpgs {
  my $self = shift;
  my ($dir) = @_;

    # get our main directory entries
  opendir DIRS, $dir or new Error->throw("General->slurp_jpgs() " .
    " Couldn't open $dir\n");
    # turn that into an array
  my @dirs;
  while(my $subdir = readdir(DIRS)) {
    if($subdir =~ /\.jpg$/) {
      push @dirs, "$dir/$subdir";
    }
  }
  closedir DIRS;

    # pop off . and ..
  shift @dirs; shift @dirs;

  return @dirs;
}

  # this routine builds an array of all the filenames that
  # do appear to be movies from a directory.
sub slurp_movies {
  my $self = shift;
  my ($dir) = @_;

    # get our main directory entries
  opendir DIRS, $dir or new Error->throw("General->slurp_jpgs() " .
    " Couldn't open $dir\n");
    # turn that into an array
  my @dirs;
  while(my $subdir = readdir(DIRS)) {
    if(
        $subdir =~ /\.mpeg$/ ||
        $subdir =~ /\.mpg$/ ||
        $subdir =~ /\.mov$/ ||
        $subdir =~ /\.wmv$/ ||
        $subdir =~ /\.asf$/ ||
        $subdir =~ /\.avi$/
      ) {
      push @dirs, "$dir/$subdir";
    }
  }
  closedir DIRS;

    # pop off . and ..
  shift @dirs; shift @dirs;

  return @dirs;
}

  # this routine builds an array of all the filenames that
  # do NOT appear to be movies from a directory.
sub slurp_non_movies {
  my $self = shift;
  my ($dir) = @_;

    # get our main directory entries
  opendir DIRS, $dir or new Error->throw("General->slurp_jpgs() " .
    " Couldn't open $dir\n");
    # turn that into an array
  my @dirs;
  while(my $subdir = readdir(DIRS)) {
    if(
        $subdir !~ /\.mpeg$/ &&
        $subdir !~ /\.mpg$/ &&
        $subdir !~ /\.mov$/ &&
        $subdir !~ /\.wmv$/ &&
        $subdir !~ /\.asf$/ &&
        $subdir !~ /\.avi$/
      ) {
      push @dirs, "$dir/$subdir";
    }
  }
  closedir DIRS;

    # pop off . and ..
  shift @dirs; shift @dirs;

  return @dirs;
}


sub is_dir {
  my $self = shift;
  my ($object) = @_;

  new Error->throw("this routine is broken!");

  if(-x $object) {
    new Error->throw("General->is_dir() returning true for $object\n");
    return 1;
  }
  else {
    return 0;
  }
}

sub slurp_gifs {
  my $self = shift;
  my ($dir) = @_;

  if(!$dir) {
    new Error->throw("General->slurp_gifs() is missing an argument!\n");
  } 

    # get our main directory entries
  opendir DIRS, $dir or new Error->throw("General->slurp_gifs() Couldn't "
    . "slurp gifs from $dir\n");
    # turn that into an array
  my @dirs;
  while(my $item = readdir(DIRS)) {
    if($item =~ /\.gif$/ && $item ne 'thumbnails') {
      push @dirs, "$dir/" . $item;
    }
  }
  closedir DIRS;

  return @dirs;
}

sub get_dimensions {
  my $self = shift;
  my ($file) = @_;

  if(! -f $file) {
    new Error->throw("General->get_dimensions can't find :$file:\n");
  }

    # slurp up the info
    # tricky, will require perlMagick
  $file =~ s/"/\\"/g;
  my $info = `/usr/X11R6/bin/identify \"$file\"`;

    # split info on the spaces
  my ($junk, $junk2, $dimensions, @more_junk) = split(/\s/, $info);
  my ($x, $y) = split (/x/, $dimensions);
  return ($x, $y, $x * $y);
}

sub get_to_last {
  my $self = shift;
  my ($full_path) = @_;
  my @elts = split(/\//, $full_path);
  pop @elts;
  my $without;
  foreach my $elt (@elts) {
    if($elt) {
      $without .= "/" . $elt;   
    }
  }
  return $without;
}

  # this routine checks a directory to see if it's empty
  # and returns true if it is.
sub is_empty {
  my $self = shift;
  my ($object) = @_;
  
  if(!$object) {
    new Error->throw("General->is_empty() wasn't passed a valid directory!\n");
  }  
  my @files = $self->slurp_files($object);

  if(!$files[0]) {
    return 1;
  }
  return 0;
}

sub make_thumbnail {
  my $self = shift;
  my ($file, $path) = @_;

    # get the dimensions of the file
  my ($x, $y) = General->get_dimensions($file);
  my $thumbsize = 150;

    # make temporary copy of the file
  my $thumb_name = General->get_last($file);
  my $new_file = "$path/$thumb_name";
  if( -f $new_file) {
    unlink $new_file;
  }

    # sample down the image, add the border and then crop it
  if($x > $y) {
    system("/usr/X11R6/bin/convert -sample $thumbsize $file $new_file");
    my ($new_x, $new_y) = General->get_dimensions($new_file);
    my $border_add = ($thumbsize - $new_y) / 2;
    system("/usr/X11R6/bin/mogrify -border x$border_add -bordercolor white " .
      "$new_file");
  }
  else {
    system("/usr/X11R6/bin/convert -sample x$thumbsize $file $new_file");
    my ($new_x, $new_y) = General->get_dimensions($new_file);
    my $border_add = ($thumbsize - $new_x) / 2;
    system("/usr/X11R6/bin/mogrify -border $border_add" . 
      "x -bordercolor white $new_file");
  }
}

  # returns the number of digits in a string
sub CountDigits {
  my $self = shift;
  my ($data) = @_;

    # chop up string
  my @data = split(//, $data);
  my $digit_count = 0;
  foreach my $elt (@data) {
    if($elt =~ /\d/) {
      $digit_count++;
    }
  }
  return $digit_count;
}

1; 
