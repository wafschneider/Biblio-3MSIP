package Biblio::3MSIP::Message;

use strict;
use warnings;
use Carp;
use Class::Accessor 'antlers';

has message_text => ( is => 'rw', isa => 'Str' );
has message_identifier => ( is => 'rw', isa => 'Int' );
has error_detection => ( is => 'rw', isa => 'Bool' );


1;