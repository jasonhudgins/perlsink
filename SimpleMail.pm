# $Id: SimpleMail.pm,v 1.3 2002-11-09 03:52:01 thanatos Exp $
package SimpleMail;

use strict;
use Error;
use strict;

sub new {
  my $proto = shift;
  my ($opt) = @_;
  my $self = {};
  my $class = ref($proto) || $proto;
  bless($self, $class);
  return $self;
}

	# return the headers
sub headers() {
	my $self = shift;

	my $headers;

		# for each header line, (as long as it isn't null append it..)
	foreach my $header_line ( @{$self->{HEADERS}} ) {
		if($header_line) {
			$headers .= $header_line;
		}
	}
	return $headers;
}

	# method to add a header
sub add_header {
	my $self = shift;
	my $header = shift;

	push @{$self->{HEADERS}}, $header;
}

	# method to "replace" a header
sub replace_header {
	my $self = shift;
	my($header) = @_;

		# determine header key (this isn't really a hash though, can't
		# be since we must retain sort order)
	my ($key, $value) = split(/:/, $header);

		# now purge any matching headers
	foreach my $header_line ( @{$self->{HEADERS}} ) {
		if($header_line =~ /^$key/) {
				# if the header_line matches the key we are replacing
				# then just null it out.. 
			$header_line = '';
		}
	}

		# now stick on the new header
	$self->add_header($header);
}

	# send all this data here to escape shell metachars
	# need to quote everything that you plan to pass along the
	# command line
sub quote {
	my $self = shift;
	my ($data) = @_;
	
		# escape shell meta-characters
	$data =~ s/([\&;\`'\\\|"*?~<>^\(\)\[\]\{\}\$])/\\$1/g;
	return $data;
}

  # set the recipient
sub recipient {
  my $self = shift;
	my ($recipient) = @_;

  $self->{RECIPIENT} = $self->quote($recipient);
}

  # set the subject
sub subject {
  my $self = shift;
	my ($subject) = @_;

	$self->replace_header("Subject: $subject");
}

  # set the message
sub message {
  my $self = shift;
	my ($message) = @_;

  $self->{MESSAGE} = $message;
}

  # set the sender
sub sender {
  my $self = shift;
	my ($sender) = @_;

  $self->{SENDER} = $self->quote($sender);
}

  # routine to send the message
sub send {
  my $self = shift;

  my $mailer; 
  if(-f '/usr/bin/sendmail') {
    $mailer = '/usr/bin/sendmail';
  }
  elsif(-f '/usr/lib/sendmail') {
    $mailer = '/usr/lib/sendmail';
  }
	elsif(-f '/usr/sbin/sendmail') {
    $mailer = '/usr/sbin/sendmail';
	}
  if(!$mailer) {
    new Error->throw("SimpleMail->send() Couldn't find a mailer!\n");
  }

		# write the message out to a temporary file
	open(TMP, ">/tmp/$$.SimpleMail") or 
		die "Couldnt' open /tmp/$$.SimpleMail for writing, $!\n";
	print TMP $self->headers() . "\n" . $self->{MESSAGE};
	close(TMP);

		# system out and mail the bitch..	
  system("$mailer -F $self->{SENDER} $self->{RECIPIENT} < /tmp/$$.SimpleMail");

		# remove the temporary file
	unlink "/tmp/$$.SimpleMail" or die "Couldn't unlink $$.SimpleMail: $!\n";
}

1;
