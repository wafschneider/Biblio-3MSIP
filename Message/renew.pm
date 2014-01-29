package Biblio::3MSIP::Message::renew;

use strict;
use warnings;
use Carp;
use Class::Accessor 'antlers';
use parent qw(Biblio::3MSIP::Message);

has third_party_allowed => ( is => 'rw', isa => 'Bool' );
has no_block => ( is => 'rw', isa => 'Bool' );
has transaction_date => ( is => 'rw', isa => 'Object' );
has nb_due_date => ( is => 'rw', isa => 'Object' );
has institution_id => ( is => 'rw', isa => 'Str' );
has patron_identifier => ( is => 'rw', isa => 'Str' );
has patron_password => ( is => 'rw', isa => 'Str' );
has item_identifier => ( is => 'rw', isa => 'Str' );
has title_identifier => ( is => 'rw', isa => 'Str' );
has terminal_password => ( is => 'rw', isa => 'Str' );
has item_properties => ( is => 'rw', isa => 'Str' );
has fee_acknowledged => ( is => 'rw', isa => 'Bool' );

sub new {
  # build the object from properties
  my $invocant = shift;
  my $class = ref($invocant) || $invocant;
  my $self = $class->SUPER::new(@_);
  $self->message_identifier(29);
  # defaults
  $self->third_party_allowed(0) unless $self->third_party_allowed;
  $self->no_block(0) unless $self->no_block;
  return $self;
}

# override message_text accessor
sub message_text {
  my $self = shift;
  my $message_text = '';
  if ($self->third_party_allowed) {
    $message_text .= 'Y';
  } else {
    $message_text .= 'N';
  }
  if ($self->no_block) {
    $message_text .= 'Y';
  } else {
    $message_text .= 'N';
  }
  # default transaction date to now unless it has been set elsewhere
  if ($self->transaction_date) {
    $message_text .= $self->to_datetime_str($self->transaction_date);
  } else {
    my $now = DateTime->now( time_zone => 'local' );
    $message_text .= $self->to_datetime_str($now);
  }
  if ($self->nb_due_date) {
    $message_text .= $self->to_datetime_str($self->nb_due_date);
  } else {
    $message_text .= '                  ';
  }
  if ($self->institution_id) {
    $message_text .= 'AO' . $self->institution_id;
  } else {
    croak "No institution_id in renew message (required field)";
  }
  if ($self->patron_identifier) {
    $message_text .= '|AA' . $self->patron_identifier;
  } else {
    croak "No patron_identifier in renew message (required field)";
  }
  $message_text .= '|AD' . $self->patron_password if $self->patron_password;
  croak "Missing item and title identifier in renew message (one is required)" unless ($self->item_identifier || $self->title_identifier);
  $message_text .= '|AB' . $self->item_identifier if $self->item_identifier;
  $message_text .= '|AJ' . $self->title_identifier if $self->title_identifier;
  $message_text .= '|AC' . $self->terminal_password if $self->terminal_password;
  $message_text .= '|CH' . $self->item_properties if $self->item_properties;
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