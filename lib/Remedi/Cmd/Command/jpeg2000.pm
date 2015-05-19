use utf8;
package Remedi::Cmd::Command::jpeg2000;

# ABSTRACT: Command class for command jpeg2000

use Moose;

extends qw(MooseX::App::Cmd::Command);

with qw(
    Remedi         
    Remedi::Log
    Remedi::JPEG2000 
    MooseX::SimpleConfig
    MooseX::Getopt
);
    
use namespace::autoclean;

sub execute {
    my ( $self, $opt, $args ) = @_;

    # you may ignore $opt, it's in the attributes anyway

    $self->info(sprintf("----- Start: %s -----", 'converting JPEG 2000'));
    $self->convert;
    $self->info(sprintf("----- Start: %s -----", 'fetching JPEG 2000 files'));
    $self->fetch;
}

__PACKAGE__->meta->make_immutable;
1;
