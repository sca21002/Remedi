use utf8;
package Remedi::Cmd::Command::csv;

# ABSTRACT: Command class for command csv  


use Moose;

extends qw(MooseX::App::Cmd::Command);

with qw(
    Remedi         
    Remedi::Log
    Remedi::CSV
    MooseX::SimpleConfig
    MooseX::Getopt
);
    
use namespace::autoclean;

sub BUILD {
    my $self = shift;
    
    $self->log; # init logging
}

sub config_any_args { { driver_args => { General => { '-UTF8' => 1 } } } }

sub execute {
    my ( $self, $opt, $args ) = @_;

    # you may ignore $opt, it's in the attributes anyway

    $self->make_csv;
    
}

__PACKAGE__->meta->make_immutable;
1;
