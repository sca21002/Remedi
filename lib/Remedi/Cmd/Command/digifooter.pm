use utf8;
package Remedi::Cmd::Command::digifooter;

# ABSTRACT: Command class for command digifooter

use Moose;

extends qw(MooseX::App::Cmd::Command);

with qw(
    Remedi         
    Remedi::DigiFooter 
    MooseX::SimpleConfig
    MooseX::Getopt
    MooseX::Log::Log4perl
);
    
use namespace::autoclean;

sub BUILD {
    my $self = shift;
    
    $self->init_logging(@_);
}


sub config_any_args { { driver_args => { General => { '-UTF8' => 1 } } } }

sub execute {
    my ( $self, $opt, $args ) = @_;

    # you may ignore $opt, it's in the attributes anyway

    $self->make_footer;
}

__PACKAGE__->meta->make_immutable;
1;