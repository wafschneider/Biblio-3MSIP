package Biblio::3MSIP::Message::hold;

use strict;
use warnings;
use Carp;
use Class::Accessor 'antlers';
use parent qw(Biblio::3MSIP::Message);

has hold_mode => ( is => 'rw', isa => 'Str' );
has transaction_date => ( is => 'rw', isa => 'Object' );
has expiration_date => ( is => 'rw', isa => 'Object' );
has pickup_location => ( is => 'rw', isa => 'Str' );
has hold_type => ( is => 'rw', isa => 'Int');
has institution_id => ( is => 'rw', isa => 'Str' );
has patron_identifier => ( is => 'rw', isa => 'Str' );
has patron_password => ( is => 'rw', isa => 'Str' );
has item_identifier => ( is => 'rw', isa => 'Str' );
has title_identifier => ( is => 'rw', isa => 'Str' );
has terminal_password => ( is => 'rw', isa => 'Str' );
has fee_acknowledged => ( is => 'rw', isa => 'Bool' );

sub new {
  # build the object from properties
  my $invocant = shift;
  my $class = ref($invocant) || $invocant;
  my $self = $class->SUPER::new(@_);
  $self->message_identifier(15);
  return $self;
}

# override message_text accessor
sub message_text {
  my $self = shift;
  my $message_text = '';
  if ($self->hold_mode) {
    if ($self->hold_mode_text) {
      $message_text .= $self->hold_mode;
    } else {
      croak 'Unsupported hold mode ' . $self->hold_mode . ' in hold message';
    }
  } else {
    croak "No hold_mode in hold message (required field)";
  }
  # default transaction date to now unless it has been set elsewhere
  if ($self->transaction_date) {
    $message_text .= $self->to_datetime_str($self->transaction_date);
  } else {
    my $now = DateTime->now( time_zone => 'local' );
    $message_text .= $self->to_datetime_str($now);
  }
  if ($self->institution_id) {
    $message_text .= 'AO' . $self->institution_id;
  } else {
    croak "No institution_id in hold message (required field)";
  }
  $message_text .= '|BW' . $self->to_datetime_str($self->expiration_date) if $self->expiration_date;
  $message_text .= '|BS' . $self->pickup_location if $self->pickup_location;
  $message_text .= '|BY' . $self->hold_type if $self->hold_type;
  if ($self->patron_identifier) {
    $message_text .= '|AA' . $self->patron_identifier;
  } else {
    croak "No patron_identifier in hold message (required field)";
  }
  $message_text .= '|AD' . $self->patron_password if $self->patron_password;
  croak "Missing item and title identifier in hold message (one is required)" unless ($self->item_identifier || $self->title_identifier);
  $message_text .= '|AB' . $self->item_identifier if $self->item_identifier;
  $message_text .= '|AJ' . $self->title_identifier if $self->title_identifier;
  $message_text .= '|AC' . $self->terminal_password if $self->terminal_password;
  if (defined($self->fee_acknowledged)) {
    $message_text .= '|BO';
    if ($self->fee_acknowledged) {
      $message_text .= 'Y';
    } else {
      $message_text .= 'N';
    }
  }
  $self->{'message_text'} = $message_text; 
  return $self->{'message_text'};
}

1;