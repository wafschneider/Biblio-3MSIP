package Biblio::3MSIP::ACS;

use strict;
use warnings;
use Carp;
use Class::Accessor 'antlers';
use Socket qw(:crlf);
use IO::Socket::INET;


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
has online => ( is => 'rw', isa => 'Bool' );
has checkin_ok => ( is => 'rw', isa => 'Bool' );
has checkout_ok => ( is => 'rw', isa => 'Bool' );
has acs_renewal_policy => ( is => 'rw', isa => 'Bool' );
has status_update_ok => ( is => 'rw', isa => 'Bool' );
has offline_ok => ( is => 'rw', isa => 'Bool' );
has acs_timeout => ( is => 'rw', isa => 'Int' );
has retries_allowed => ( is => 'rw', isa => 'Int' );
has screen_message => ( is => 'rw', isa => 'ArrayRef' );
has status_print_line => ( is => 'rw', isa => 'ArrayRef' );

# defaults
my $default_sip_version = '2.00';
my $default_connection_method = 'socket';
my $default_eol = $CR;

# override new
sub new {
  my $invocant = shift;
  my $class = ref($invocant) || $invocant;
  my $self = $class->SUPER::new(@_);
  $self->{'connection_method'} = $default_connection_method unless $self->connection_method;
  $self->sip_version($default_sip_version) unless $self->sip_version;
  $self->eol($default_eol) unless $self->eol;
  if ($self->connection_method eq 'socket') {
    unless ($self->host) {
      carp "Can't create ACS object: no host name or address";
      return undef;
    }
    unless ($self->port) {
      carp "Can't create ACS object: no port number";
      return undef;
    }
    my $socket;
    unless ($socket = IO::Socket::INET->new( PeerAddr => $self->host,
                                             PeerPort => $self->port,
                                             Proto => 'tcp' )) {
      carp "Can't create ACS object: couldn't connect to " . $self->host . ":" . $self->port . " : $!";
      return undef;
    }
    $self->{'connection'} = $socket;
    if ($self->user || $self->password) {
      # should login before getting ACS status response
      carp "Login message unsupported";
    }
    my $acs_status = $self->sc_status(0,undef,$self->sip_version);
    if ($acs_status) {
      $self->update_acs_status($acs_status);      
    } else {
      carp "Can't create ACS object: No ACS Status message";
      return undef;
    }
  } else {
    carp "Can't create ACS object: unsupported connection method " . $self->connection_method;
    return undef;
  }
  return $self;
}

sub sc_status {
  # create and send an SC status message
  # return ACS status message
  my ($self,$status_code,$print_width,$sip_version) = @_;
  my $sc_status = Biblio::3MSIP::Message::sc_status->new(
    {
      status_code => $status_code,
      print_width => $print_width,
      sip_version => $sip_version,
    }
  );
  
  
}

sub update_acs_status {
  # update status parameters based on ACS status message
  my ($self,$acs_status) = @_;
  unless ($acs_status && (ref($acs_status) eq 'Biblio::3MSIP::Message::acs_status')) {
    carp 'Can\'t update ACS status: invalid or missing ACS Status message';
    return undef;
  }
  $self->online($acs_status->online);
  $self->checkin_ok($acs_status->checkin_ok);
  $self->checkout_ok($acs_status->checkout_ok);
  $self->acs_renewal_policy($acs_status->acs_renewal_policy);
  $self->status_update_ok($acs_status->status_update_ok);
  $self->offline_ok($acs_status->offline_ok);
  $self->acs_timeout($acs_status->acs_timeout);
  $self->retries_allowed($acs_status->retries_allowed);
  $self->sip_version($acs_status->protocol_version);
  $self->screen_message($acs_status->screen_message);
  $self->status_print_line($acs_status->print_line);
  1;
}

sub _send_message {
  # private method to send message to ACS
  my ($self, $message) = @_;
  my $response;
  if ($self->connection_method eq 'socket') {
    my $message_str = $message->as_string;
    if ($self->error_detection) {
      # add sequence and checksum
    }
    $self->connection->send($message_str . $self->eol);
    my $response_str = <$self->connection>;
    
    
  } else {
    carp "Can't send message: unsupported connection method " . $self->connection_method;
  }
  return $response;
}

1;