use utf8;
package Remedi::JPEG2000::App;

# ABSTRACT: Application class for command jpeg2000

use Moose;

with qw(
    Remedi         
    Remedi::JPEG2000
    MooseX::SimpleConfig
    MooseX::Getopt
    MooseX::Log::Log4perl
);
    
use namespace::autoclean;

sub BUILD {
    my $self = shift;
    
    $self->init_logging(@_);
}

__PACKAGE__->meta->make_immutable;

1;  
