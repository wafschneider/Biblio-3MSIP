package Biblio::3MSIP::Message::renew_response;

use strict;
use warnings;
use Carp;
use Class::Accessor 'antlers';
use parent qw(Biblio::3MSIP::Message);

has ok => ( is => 'rw', isa => 'Bool' );
has renewal_ok => ( is => 'rw', isa => 'Bool' );
has magnetic_media => ( is => 'rw', isa => 'Str' );
has desensitize => ( is => 'rw', isa => 'Str' );
has transaction_date => ( is => 'rw', isa => 'Object' );
has institution_id => ( is => 'rw', isa => 'Str' );
has patron_identifier => ( is => 'rw', isa => 'Str' );
has item_identifier => ( is => 'rw', isa => 'Str' );
has title_identifier => ( is => 'rw', isa => 'Str' );
has due_date => ( is => 'rw', isa => 'Object' );
has fee_type => ( is => 'rw', isa => 'Int' );
has security_inhibit => ( is => 'rw', isa => 'Bool' );
has currency_type => ( is => 'rw', isa => 'Str' ); # ISO 4217:1995
has fee_amount => ( is => 'rw', isa => 'Num' );
has media_type => ( is => 'rw', isa => 'Int' );
has item_properties => ( is => 'rw', isa => 'Str' );
has transaction_id => ( is => 'rw', isa => 'Str' );
has screen_message => ( is => 'rw', isa => 'ArrayRef' );
has print_line => ( is => 'rw', isa => 'ArrayRef' );

sub new {
  # build the object from message_text
  my $invocant = shift;
  my $class = ref($invocant) || $invocant;
  my $self = $class->SUPER::new(@_);
  $self->message_identifier(30);
  if ($self->message_text) {
    # parse fixed fields
    my $fixed = substr($self->message_text,0,22);
    $self->ok(substr($fixed,0,1));
    if (substr($fixed,1,1) eq 'Y') {
      $self->renewal_ok(1);
    } else {
      $self->renewal_ok(0);
    }
    $self->magnetic_media(substr($fixed,2,1));
    $self->desensitize(substr($fixed,3,1));
    $self->transaction_date($self->to_datetime(substr($fixed,4,18)));
    my @variable = split(/\|/,substr($self->message_text,22));
    my (@screen_message,@print_line);
    foreach my $variable (@variable) {
      my $field_id = substr($variable,0,2);
      my $value = substr($variable,2);
      if ($field_id eq 'AO') {
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
      } elsif ($field_id eq 'AH') {
        # due date
        # TODO Horizon default is MM/DD/YY, why would you do that??
        my @due_date = split(/\//,$value);
        if ($due_date[2] > 70) {
          $due_date[2] += 1900;
        } else {
          $due_date[2] += 2000;
        }
        my $due_date = DateTime->new(
          month => $due_date[0],
          day => $due_date[1],
          year => $due_date[2]
        );
        $self->due_date($due_date);
      } elsif ($field_id eq 'BT') {
        # fee type
        $self->fee_type($value);
      } elsif ($field_id eq 'CI') {
        # security inhibit
        if ($value eq 'Y') {
          $self->security_inhibit(1);
        } else {
          $self->security_inhibit(0);
        }
      } elsif ($field_id eq 'BH') {
        # currency type
        $self->currency_type($value);
      } elsif ($field_id eq 'BV') {
        $self->fee_amount($value);
      } elsif ($field_id eq 'CK') {
        $self->media_type($value);
      } elsif ($field_id eq 'CH') {
        $self->item_properties($value);
      } elsif ($field_id eq 'BK') {
        $self->transaction_id($value);
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