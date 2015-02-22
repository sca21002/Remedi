use utf8;
package Remedi::Cmd::Command::create_thumbnail;

# ABSTRACT: Command class for command create_thumbnail

use Moose;

extends qw(MooseX::App::Cmd::Command);

with qw(
    Remedi      
    Remedi::Thumbnail   
    MooseX::SimpleConfig
    MooseX::Getopt
    MooseX::Log::Log4perl
);
    
use namespace::autoclean;

sub BUILD {
    my $self = shift;
    
    $self->init_logging(@_);
}



sub execute {
    my ( $self, $opt, $args ) = @_;

    # you may ignore $opt, it's in the attributes anyway

    $self->create_thumbnail();
}

__PACKAGE__->meta->make_immutable;
1;
