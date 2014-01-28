package Biblio::3MSIP::Message::sc_status;

use strict;
use warnings;
use Carp;
use Class::Accessor 'antlers';
use parent qw(Biblio::3MSIP::Message);

has status_code => ( is => 'rw', isa => 'Int' );
has print_width => ( is => 'rw', isa => 'Int' );
has sip_version => ( is => 'rw', isa => 'Str');

sub new {
  # build the object from properties
  my $invocant = shift;
  my $class = ref($invocant) || $invocant;
  my $self = $class->SUPER::new(@_);
  $self->message_identifier(99);
  return $self;
}

# override message_text accessor
sub message_text {
  my $self = shift;
  $self->{'message_text'} = sprintf('%1u',$self->status_code) . sprintf('%03u',$self->print_width) . $self->sip_version;
  return $self->{'message_text'};
}

1;