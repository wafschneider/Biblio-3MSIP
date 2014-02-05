package Biblio::3MSIP::Message::hold_response;

use strict;
use warnings;
use Carp;
use Class::Accessor 'antlers';
use parent qw(Biblio::3MSIP::Message);

has ok => ( is => 'rw', isa => 'Bool' );
has available => ( is => 'rw', isa => 'Bool' );
has transaction_date => ( is => 'rw', isa => 'Object' );
has expiration_date => ( is => 'rw', isa => 'Object' );
has queue_position => ( is => 'rw', isa => 'Int');
has pickup_location => ( is => 'rw', isa => 'Str' );
has institution_id => ( is => 'rw', isa => 'Str' );
has patron_identifier => ( is => 'rw', isa => 'Str' );
has item_identifier => ( is => 'rw', isa => 'Str' );
has title_identifier => ( is => 'rw', isa => 'Str' );
has hold_identifier => ( is => 'rw', isa => 'Str' );
has screen_message => ( is => 'rw', isa => 'ArrayRef' );
has print_line => ( is => 'rw', isa => 'ArrayRef' );

sub new {
  # build the object from message_text
  my $invocant = shift;
  my $class = ref($invocant) || $invocant;
  my $self = $class->SUPER::new(@_);
  $self->message_identifier(16);
  if ($self->message_text) {
    # parse fixed fields
    my $fixed = substr($self->message_text,0,20);
    $self->ok(substr($fixed,0,1));
    if (substr($fixed,1,1) eq 'Y') {
      $self->available(1);
    } else {
      $self->available(0);
    }
    $self->transaction_date($self->to_datetime(substr($fixed,2,18)));
    my @variable = split(/\|/,substr($self->message_text,20));
    my (@screen_message,@print_line);
    foreach my $variable (@variable) {
      my $field_id = substr($variable,0,2);
      my $value = substr($variable,2);
      if ($field_id eq 'BW') {
        # expiration date
        $self->expiration_date($self->to_datetime($value));
      } elsif ($field_id eq 'BR') {
        # queue position
        $self->queue_position($value);
      } elsif ($field_id eq 'BS') {
        # pickup location
        $self->pickup_location($value);
      } elsif ($field_id eq 'AO') {
        # institution id
        $self->institution_id($value);
      } elsif ($field_id eq 'AA') {
        # patron identifier
        $self->patron_identifier($value);
      } elsif ($field_id eq 'AB') {
        # item identifier
        $self->item_identifier($value);
      } elsif ($field_id eq 'AJ') {
        # title identifier
        $self->title_identifier($value);
      } elsif ($field_id eq 'NR') {
        $self->hold_identifier($value);
      } elsif ($field_id eq 'AF') {
        # screen message
        push(@screen_message,$value);
        $self->screen_message(\@screen_message);
      } elsif ($field_id eq 'AG') {
        # print line
        push(@print_line,$value);
        $self->print_line(\@print_line);
      } else {
        carp "Unsupported field $field_id with value $value in renew_response message";
      }
    }
  }
  return $self;
}

1;