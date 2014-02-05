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
  my $fee_type_text;
  if ($self->fee_type) {
    my @fee_type = (undef,'other/unknown','administrative','damage','overdue','processing','rental','replacement','computer access charge','hold fee');
    $fee_type_text = $fee_type[$self->fee_type]?$fee_type[$self->fee_type]:undef;
  }
  return $fee_type_text;
}

sub media_type_text {
  # look up media type text
  my $self = shift;
  my $media_type_text;
  if ($self->media_type) {
    my @media_type = ('other','book','magazine','bound journal','audio tape','video tape','CD/CDROM','diskette','book with diskette','book with CD','book with audio tape');
    $media_type_text = $media_type[$self->media_type]?$media_type[$self->media_type]:undef;
  }
  return $media_type_text;
}

sub hold_mode_text {
  # look up hold mode text
  my $self = shift;
  my $hold_mode_text;
  if ($self->hold_mode) {
    my %hold_mode= ('+','add','-','delete','*','change');
    $hold_mode_text = $hold_mode{$self->hold_mode}?$hold_mode{$self->hold_mode}:undef;
  }
  return $hold_mode_text;
}

sub hold_type {
  # look up hold type text
  my $self = shift;
  my $hold_type_text;
  if ($self->hold_type) {
    my @hold_type = (undef,'other','any copy','specific copy','any copy at a single location');
    $hold_type_text = $hold_type[$self->hold_type]?$hold_type[$self->hold_type]:undef;
  }
  return $hold_type_text;
}

1;