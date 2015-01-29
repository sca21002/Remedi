use utf8;
package Remedi::Cmd::Command::jpeg2000;

# ABSTRACT: Command class for command jpeg2000

use Moose;

extends qw(MooseX::App::Cmd::Command);

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


sub config_any_args { { driver_args => { General => { '-UTF8' => 1 } } } }

sub execute {
    my ( $self, $opt, $args ) = @_;

    # you may ignore $opt, it's in the attributes anyway

    $self->convert;
}

__PACKAGE__->meta->make_immutable;
1;
