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
has screen_message => ( is => 'rw', isa => 'ArrayRef' );
has print_line => ( is => 'rw', isa => 'ArrayRef' );
has vendor_information => ( is => 'rw', isa => 'Str');

sub new {
  # build the object from message_text
  my $invocant = shift;
  my $class = ref($invocant) || $invocant;
  my $self = $class->SUPER::new(@_);
  $self->message_identifier(98);
  if ($self->message_text) {
    # parse fixed fields
    my $fixed = substr($self->message_text,0,34);
    if (substr($fixed,0,1) eq 'Y') {
      $self->online_status(1);
    } else {
      $self->online_status(0);
    }
    if (substr($fixed,1,1) eq 'Y') {
      $self->checkin_ok(1);
    } else {
      $self->checkin_ok(0);
    }
    if (substr($fixed,2,1) eq 'Y') {
      $self->checkout_ok(1);
    } else {
      $self->checkout_ok(0);
    }
    if (substr($fixed,3,1) eq 'Y') {
      $self->acs_renewal_policy(1);
    } else {
      $self->acs_renewal_policy(0);
    }
    if (substr($fixed,4,1) eq 'Y') {
      $self->status_update_ok(1);
    } else {
      $self->status_update_ok(0);
    }
    if (substr($fixed,5,1) eq 'Y') {
      $self->offline_ok(1);
    } else {
      $self->offline_ok(0);
    }
    $self->acs_timeout(substr($fixed,6,3)/10);
    $self->retries_allowed(substr($fixed,9,3)+0);
    $self->date_time($self->convert_datetime_sync(substr($fixed,12,18)));
    $self->sip_version(substr($fixed,30,4));
    # parse variable-length fields
    my @variable = split(/\|/,substr($self->message_text,34));
    my (@screen_message,@print_line);
    foreach my $variable (@variable) {
      my $field_id = substr($variable,0,2);
      my $value = substr($variable,2);
      if ($field_id eq 'AO') {
        # institution id
        $self->institution_id($value);
      } elsif ($field_id eq 'AM') {
        # library name
        $self->library_name($value);
      } elsif ($field_id eq 'BX') {
        # supported messages
        my %supported_messages;
        $supported_messages{patron_status_request} = 1 if (substr($value,0,1) eq 'Y');
        $supported_messages{checkout} = 1 if (substr($value,1,1) eq 'Y');
        $supported_messages{checkin} = 1 if (substr($value,2,1) eq 'Y');
        $supported_messages{block_patron} = 1 if (substr($value,3,1) eq 'Y');
        $supported_messages{sc_status} = 1 if (substr($value,4,1) eq 'Y');
        $supported_messages{request_resend} = 1 if (substr($value,5,1) eq 'Y');
        $supported_messages{login} = 1 if (substr($value,6,1) eq 'Y');
        $supported_messages{patron_information} = 1 if (substr($value,7,1) eq 'Y');
        $supported_messages{end_patron_session} = 1 if (substr($value,8,1) eq 'Y');
        $supported_messages{fee_paid} = 1 if (substr($value,9,1) eq 'Y');
        $supported_messages{item_information} = 1 if (substr($value,10,1) eq 'Y');
        $supported_messages{item_status_update} = 1 if (substr($value,11,1) eq 'Y');
        $supported_messages{patron_enable} = 1 if (substr($value,12,1) eq 'Y');
        $supported_messages{hold} = 1 if (substr($value,13,1) eq 'Y');
        $supported_messages{renew} = 1 if (substr($value,14,1) eq 'Y');
        $supported_messages{renew_all} = 1 if (substr($value,15,1) eq 'Y');
        $self->supported_messages(\%supported_messages);
      } elsif ($field_id eq 'AN') {
        # terminal location
        $self->terminal_location($value);
      } elsif ($field_id eq 'AF') {
        # screen message
        push(@screen_message,$value);
        $self->screen_message(\@screen_message);
      } elsif ($field_id eq 'AG') {
        # print line
        push(@print_line,$value);
        $self->print_line(\@print_line);
      } elsif ($field_id eq 'VN') {
        # Vendor information
        $self->vendor_information($value);
      } else {
        carp "Unsupported field $field_id with value $value in acs_status message";
      }
    }
  }
  return $self;
}

1;
