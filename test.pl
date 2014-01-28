#!c:\perl\bin\perl.exe

use strict;
use warnings;
use Biblio::3MSIP::ACS;
use Data::Dumper;

my $acs = Biblio::3MSIP::ACS->new( { host => 'gogottes',
                                     port => '4552' } );

print Dumper($acs->sc_status(0,40,'2.00')) . "\n";

exit;