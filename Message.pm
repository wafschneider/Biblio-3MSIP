package Biblio::3MSIP::Message;

use strict;
use warnings;
use Carp;
use Class::Accessor 'antlers';
use DateTime;

has message_text => ( is => 'ro', isa => 'Str' );
has message_identifier => ( is => 'rw', isa => 'Int' );

sub to_datetime {
  # convert date/time string (ANSI X3.30, X3.43) into DateTime object
  my $self = shift;
  my $datetime_str = shift;
  my $datetime = DateTime->new(
    year => substr($datetime_str,0,4),
    month => substr($datetime_str,4,2),
    day => substr($datetime_str,6,2),
    hour => substr($datetime_str,12,2),
    minute => substr($datetime_str,14,2),
    second => substr($datetime_str,16)
  );
  return $datetime;
}

sub to_datetime_str {
  # convert DateTime object into date/time string (ANSI X3.30, X.3.43)
  my ($self,$datetime) = @_;
  my $datetime_str = $datetime->year . sprintf('%02d',$datetime->month) . sprintf('%02d',$datetime->day) . '    ' . sprintf('%02d',$datetime->hour) . sprintf('%02d',$datetime->minute) . sprintf('%02d',$datetime->second);
  return $datetime_str;
}

sub fee_type_text {
  # look up fee type text
  my $self = shift;
  if ($self->fee_type) {
    my @fee_type = ('other/unknown','administrative','damage','overdue','processing','rental','replacement','computer access charge','hold fee');
    return $fee_type[$self->fee_type - 1];
  } else {
    return undef;
  } 
}

sub media_type_text {
  # look up media type text
  my $self = shift;
  if ($self->media_type) {
    my @media_type = ('other','book','magazine','bound journal','audio tape','video tape','CD/CDROM','diskette','book with diskette','book with CD','book with audio tape');
    return $media_type[$self->media_type];
  } else {
    return undef;
  }
}

1;