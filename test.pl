#!c:\perl\bin\perl.exe

use strict;
use warnings;
use Biblio::3MSIP::ACS;

my $acs = Biblio::3MSIP::ACS->new( { host => 'gogottes',
                                     port => '4552' } );

exit;