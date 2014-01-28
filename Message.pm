package Biblio::3MSIP::Message;

use strict;
use warnings;
use Carp;
use Class::Accessor 'antlers';

has message_text => ( is => 'ro', isa => 'Str' );
has message_identifier => ( is => 'rw', isa => 'Int' );

1;