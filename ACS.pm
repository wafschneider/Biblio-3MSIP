package Biblio::3MSIP::ACS;

use strict;
use warnings;
use Carp;
use Class::Accessor 'antlers';
use Socket qw(:crlf);
use IO::Socket::INET;
use Biblio::3MSIP::Message::sc_status;
use Biblio::3MSIP::Message::acs_status;
use Biblio::3MSIP::Message::renew;
use Biblio::3MSIP::Message::renew_response;
use Biblio::3MSIP::Message::hold;
use Biblio::3MSIP::Message::hold_response;
$| = 1;


# attributes
has host => ( is => 'ro', isa => 'Str' );
has port => ( is => 'ro', isa => 'Str' );
has institution_id => ( is => 'rw', isa => 'Str' );
has sip_version => ( is => 'rw', isa => 'Str' );
has connection_method => ( is => 'ro', isa => 'Str' );
has sip_flavor => ( is => 'rw', isa => 'Str' );
has eol => ( is => 'rw', isa => 'Str' );
has error_detection => ( is => 'rw', isa => 'Bool' );
has sequence => ( is => 'rw', isa => 'Int' );
has user => ( is => 'ro', isa => 'Str' );
has password => ( is => 'ro', isa => 'Str' );
has online_status => ( is => 'rw', isa => 'Bool' );
has checkin_ok => ( is => 'rw', isa => 'Bool' );
has checkout_ok => ( is => 'rw', isa => 'Bool' );
has acs_renewal_policy => ( is => 'rw', isa => 'Bool' );
has status_update_ok => ( is => 'rw', isa => 'Bool' );
has offline_ok => ( is => 'rw', isa => 'Bool' );
has acs_timeout => ( is => 'rw', isa => 'Int' );
has retries_allowed => ( is => 'rw', isa => 'Int' );
has supported_messages => ( is => 'rw', isa => 'HashRef' );
has screen_message => ( is => 'rw', isa => 'ArrayRef' );
has status_print_line => ( is => 'rw', isa => 'ArrayRef' );
has vendor_information => ( is => 'rw', isa => 'Str' );
has print_width => ( is => 'rw', isa => 'Int' );
has connected => ( is => 'rw', isa => 'Bool');
has connection_timeout => ( is => 'rw', isa => 'Num');

# defaults
my $default_sip_version = '2.00';
my $default_connection_method = 'socket';
my $default_eol = $CR;
my $default_retries_allowed = 3;
my $default_print_width = 40;
my $default_connection_timeout = 10;

# override new
sub new {
  my $invocant = shift;
  my $class = ref($invocant) || $invocant;
  my $self = $class->SUPER::new(@_);
  $self->{'connection_method'} = $default_connection_method unless $self->connection_method;
  $self->connection_timeout($default_connection_timeout) unless $self->connection_timeout;
  $self->sip_version($default_sip_version) unless $self->sip_version;
  $self->eol($default_eol) unless $self->eol;
  $self->retries_allowed($default_retries_allowed) unless $self->retries_allowed;
  $self->print_width($default_print_width) unless $self->print_width;
  $self->sequence(0);
    if ($self->connection_method eq 'socket') {
    unless ($self->host) {
      carp "Can't create ACS object: no host name or address";
      return undef;
    }
    unless ($self->port) {
      carp "Can't create ACS object: no port number";
      return undef;
    }
    my $socket = $self->_socket_connect();
    $self->{'connection'} = $socket;
    if ($self->{'connection'}) {
      binmode($self->{'connection'},':utf8');
      if ($self->user || $self->password) {
        # should login before getting ACS status response
        carp "Login message unsupported";
      }
      my $sc_status = Biblio::3MSIP::Message::sc_status->new(
        {
          status_code => 0,
          print_width => $self->print_width,
          sip_version => $self->sip_version
        }
      );
      my $acs_status = $self->sc_status($sc_status);
      if ($acs_status) {
        $self->update_acs_status($acs_status);      
      }
    }
  } else {
    carp "Can't create ACS object: unsupported connection method " . $self->connection_method;
    return undef;
  }
  return $self;
}

# messages
sub sc_status {
  # send an SC status message
  # return ACS status message
  my ($self,$sc_status) = @_;
  my $response;
  my $response_str = $self->_send_message($sc_status);
  if ($response_str && substr($response_str,0,2) eq '98') {
    $response = Biblio::3MSIP::Message::acs_status->new(
    {
      message_text => substr($response_str,2)
    }
    );
  } else {
    carp "SC status message didn't return ACS status response";
  }
  return $response;
}

sub renew {
  # send a renew message
  # return renew response message
  my ($self,$renew) = @_;
  $renew->institution_id($self->institution_id) unless $renew->institution_id;
  my $response;
  my $response_str = $self->_send_message($renew);
  if ($response_str && substr($response_str,0,2) eq '30') {
    $response = Biblio::3MSIP::Message::renew_response->new(
      {
        message_text => substr($response_str,2)
      }
    );
  } else {
    carp "Renew message didn't return renew response";
  }
  return $response;
}

# HERE I AM
sub hold {
  # send a hold message
  # return a hold response message
  my ($self,$hold) = @_;
  $hold->institution_id($self->institution_id) unless $hold->institution_id;
  my $response;
  my $response_str = $self->_send_message($hold);
  if ($response_str && substr($response_str,0,2) eq '16') {
    $response = Biblio::3MSIP::Message::hold_response->new(
      {
        message_text => substr($response_str,2)
      }
    );
  } else {
    carp "Hold message didn't return hold response";
  }
  return $response;
}

# other methods

# override connected accessor
sub connected {
  my $self = shift;
  $self->{connected} = undef;
  if ($self->connection_method eq 'socket') {
    if ($self->{connection}) {
      if ($self->{connection}->connected) {
        $self->{connected} = 1;
      } else {
        carp "Connection lost";
        $self->{connection}->shutdown(2);
        undef($self->{connection});
      }
    }
  } else {
    carp "Can't return connected status: Unsupported connection method " . $self->connection_method;
  }
  return $self->{connected};
}

sub update_acs_status {
  # update status parameters based on ACS status message
  my ($self,$acs_status) = @_;
  unless ($acs_status && (ref($acs_status) eq 'Biblio::3MSIP::Message::acs_status')) {
    carp 'Can\'t update ACS status: invalid or missing ACS Status message';
    return undef;
  }
  $self->online_status($acs_status->online_status);
  $self->checkin_ok($acs_status->checkin_ok);
  $self->checkout_ok($acs_status->checkout_ok);
  $self->acs_renewal_policy($acs_status->acs_renewal_policy);
  $self->status_update_ok($acs_status->status_update_ok);
  $self->offline_ok($acs_status->offline_ok);
  $self->acs_timeout($acs_status->acs_timeout);
  if ($acs_status->retries_allowed != 999) {
    $self->retries_allowed($acs_status->retries_allowed);
  }
  $self->sip_version($acs_status->sip_version);
  $self->supported_messages($acs_status->supported_messages);
  $self->screen_message($acs_status->screen_message);
  $self->status_print_line($acs_status->print_line);
  $self->vendor_information($acs_status->vendor_information);
  # update institution id if not already defined
  $self->institution_id($acs_status->institution_id) unless $self->institution_id;
  1;
}

sub _socket_connect {
  my $self = shift;
  my $socket;
  unless ($socket = IO::Socket::INET->new( PeerAddr => $self->host,
                                           PeerPort => $self->port,
                                           Proto => 'tcp',
                                           Timeout => $self->connection_timeout )) {
    carp "Couldn't connect to " . $self->host . ":" . $self->port . " : $!";
  }
  return $socket;
}

sub _send_message {
  # private method to send message to ACS
  # return the raw response text to calling method for parsing
  # TODO turn on error handling if the server sends sequence/checksum
  my ($self, $message) = @_;
  my $response;
  if ($self->connection_method eq 'socket') {
    # try to reconnect if socket is disconnected
    unless ($self->connected) {
      my $socket = $self->_socket_connect();
      if ($socket) {
        binmode($socket,':utf8');
        $self->{connection} = $socket;
      } else {
        return undef;
      }
    }
    my $connection = $self->{'connection'};
    my $message_str = sprintf('%02u',$message->message_identifier) . $message->message_text; 
    if ($self->error_detection) {
      # TODO add sequence and checksum
    }
    # parse $response_str to make sure it's not a 96
    # try retries_allowed, then croak
    my $attempt = 0;
    until ($response) {
      $response = '';
      $connection->send($message_str . $self->eol);
      my $buffer;
      my $eol = $self->eol;
      do {
        $connection->recv($buffer,1024);
        $response .= $buffer;
      } while ($buffer !~ /$eol/);
      $response =~ s/[\r\n]//g;
      if (substr($response,0,2) eq '96') {
        if ($attempt == $self->retries_allowed) {
          croak "ACS unable to respond: $response";
        } else {
          carp "Resending message in response to 96 from ACS";
          undef($response);
          $attempt++;
        }        
      }
    }
    if ($self->error_detection) {
      # TODO make sure sequence and checksum match
      # strip off sequence and checksum
      $response =~ s/(AY\d{1})?AZ.*$//;
    }
  } else {
    carp "Can't send message: unsupported connection method " . $self->connection_method;
  }
  return $response;
}

# checksum utility
# cribbed from GPLS (Evergreen folks - presumably Mike Rylander)
sub _chksum {
  my $s = shift;
  my $sum = 0;
  ## add up the ascii values of the characters
  foreach my $val (unpack("C*", $s)) {
    $sum += $val;
  }
  # get the bitwise complement
  my $comp  = ~$sum;

  ## add one to the complement
  $comp ++;
  my $hexcomp = $comp;
  # get the hex value and return the 4 rightmost hex digits
  my $hex = sprintf("%X", $hexcomp);
  return (substr $hex,-4);
}


1;