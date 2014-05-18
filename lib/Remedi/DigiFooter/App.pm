use utf8;
package Remedi::DigiFooter::App;

# ABSTRACT: Application class for command digifooter

use Moose;

with qw(
    Remedi         
    Remedi::DigiFooter 
    MooseX::SimpleConfig
    MooseX::Getopt
    MooseX::Log::Log4perl
);
    
use namespace::autoclean;

__PACKAGE__->meta->make_immutable;

1;  