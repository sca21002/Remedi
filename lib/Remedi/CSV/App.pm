use utf8;
package Remedi::CSV::App;

# ABSTRACT: Application class for command csv

use Moose;

with qw(
    Remedi         
    Remedi::Log
    Remedi::CSV
    MooseX::SimpleConfig
    MooseX::Getopt
    MooseX::Log::Log4perl
);
    
use namespace::autoclean;

sub BUILD {
    my $self = shift;
    
    $self->log;    # init logging
}

__PACKAGE__->meta->make_immutable;

1;  
