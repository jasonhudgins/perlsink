# Error.pm
# $Id: Error.pm,v 1.1.1.1 2002-04-09 18:35:41 thanatos Exp $

package Error;
use strict;
use POSIX;

sub new {
  my $proto = shift;
  my ($opt) = @_;
  my $class = ref($proto) || $proto;
  my $self = {};
  bless($self, $class);

    # set the mode to console
  $self->{MODE} = 'console';
    # but chance it if we are going via http
  if($ENV{SERVER_SOFTWARE}) {
    $self->{MODE} = 'http';
  }

  return $self;
}

sub throw {
  my $self = shift;
  my ($error) = @_;

    # build our stack trace with some magic
  my @c = (1 .. 6);
  my $stack;
  for(my $i=0; @c; $i++) {
	@c=caller($i);
  if(@c) {
			$stack.="\t$c[3] at $c[1]:$c[2]\n";
		}
	}

    # we have to turn on autoflush
  $| = 1;
  if($self->{MODE} eq 'http') {
    print "Content-Type: text/html\n\n";
    print "<html><head><title>Caught an Exception</title></head>\n";
    print "<body bgcolor=\"#fFfFfF\"><h3>$error<br>";
    print $error . "<br>STACK TRACE:<br>";
    $stack =~ s/\n/<br>/g;
    print $stack;
    print "END STACK TRACE<br>";
    print "</h3></body>\n";
    print "</html>\n\n";
  }
  else {
    print $error . "\nSTACK TRACE:\n";
    print $stack;
    print "END STACK TRACE\n";
  }

  POSIX:_exit(0);
} 

1;
