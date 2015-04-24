use utf8;
package Remedi::Cmd::Command::create_thumbnails;

# ABSTRACT: Command class for command create_thumbnails

use Moose;

extends qw(MooseX::App::Cmd::Command);

with qw(
    Remedi
    Remedi::Log      
    Remedi::Thumbnail 
    MooseX::SimpleConfig
    MooseX::Getopt
);
    
use namespace::autoclean;

sub execute {
    my ( $self, $opt, $args ) = @_;

    # you may ignore $opt, it's in the attributes anyway
    my $cmd = 'create_thumbnails';
    $self->info(sprintf("----- Start: %s -----", $cmd));
    $self->create_thumbnails();
}

__PACKAGE__->meta->make_immutable;
1;
