package Biblio::3MSIP::Message;

use strict;
use warnings;
use Carp;
use Class::Accessor 'antlers';
use DateTime;

has message_text => ( is => 'ro', isa => 'Str' );
has message_identifier => ( is => 'rw', isa => 'Int' );

sub convert_datetime_sync {
  # convert date/time sync string (ANSI X3.30, X3.43) into DateTime object
  my $self = shift;
  my $datetime_sync = shift;
  my $datetime = DateTime->new(
    year => substr($datetime_sync,0,4),
    month => substr($datetime_sync,4,2),
    day => substr($datetime_sync,6,2),
    hour => substr($datetime_sync,12,2),
    minute => substr($datetime_sync,14,2),
    second => substr($datetime_sync,16)
  );
  return $datetime;
}

1;