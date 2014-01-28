package Biblio::3MSIP::Message::acs_status;

use strict;
use warnings;
use Carp;
use Class::Accessor 'antlers';
use parent qw(Biblio::3MSIP::Message);

has online_status => ( is => 'rw', isa => 'Bool' );
has checkin_ok => ( is => 'rw', isa => 'Bool' );
has checkout_ok => ( is => 'rw', isa => 'Bool' );
has acs_renewal_policy => ( is => 'rw', isa => 'Bool' );
has status_update_ok => ( is => 'rw', isa => 'Bool' );
has offline_ok => ( is => 'rw', isa => 'Bool' );
has acs_timeout => ( is => 'rw', isa => 'Int' );
has retries_allowed => ( is => 'rw', isa => 'Int' );
has date_time => ( is => 'rw', isa => 'Object' );
has sip_version => ( is => 'rw', isa => 'Str' );
has institution_id => ( is => 'rw', isa => 'Str' );
has library_name => ( is => 'rw', isa => 'Str' );
has supported_messages => ( is => 'rw', isa => 'HashRef' );
has terminal_location => ( is => 'rw', isa => 'Str' );
has screen_message => ( is => 'rw', isa => 'Str' );
has print_line => ( is => 'rw', isa => 'Str' );

sub new {
  # build the object from message_text
  my $invocant = shift;
  my $class = ref($invocant) || $invocant;
  my $self = $class->SUPER::new(@_);
  $self->message_identifier(98);
  if ($self->message_text) {
    my $message = $self->message_text;
    if (substr($message,0,1) eq 'Y') {
      $self->online_status(1);
    } else {
      $self->online_status(0);
    }
    if (substr($message,1,1) eq 'Y') {
      $self->checkin_ok(1);
    } else {
      $self->checkin_ok(0);
    }
    if (substr($message,2,1) eq 'Y') {
      $self->checkout_ok(1);
    } else {
      $self->checkout_ok(0);
    }
    if (substr($message,3,1) eq 'Y') {
      $self->acs_renewal_policy(1);
    } else {
      $self->acs_renewal_policy(0);
    }
    if (substr($message,4,1) eq 'Y') {
      $self->status_update_ok(1);
    } else {
      $self->status_update_ok(0);
    }
    if (substr($message,5,1) eq 'Y') {
      $self->offline_ok(1);
    } else {
      $self->offline_ok(0);
    }
    $self->acs_timeout(substr($message,6,3)/10);
    $self->retries_allowed(substr($message,9,3)+0);
    # HERE I AM convert this to DateTime object
    $self->date_time(substr($message,12,18));
    $self->sip_version(substr($message,30,4));
  }
  return $self;
}

1;
