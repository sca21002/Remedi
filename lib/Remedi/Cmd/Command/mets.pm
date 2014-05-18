use utf8;
package Remedi::Cmd::Command::mets;

# ABSTRACT: Command class for command mets

use Moose;

extends qw(MooseX::App::Cmd::Command);

with qw(
    Remedi         
    Remedi::METS 
    MooseX::SimpleConfig
    MooseX::Getopt
    MooseX::Log::Log4perl
);
    
use namespace::autoclean;

sub BUILD {
    my $self = shift;
    
    $self->init_logging(@_);
    $self->log->logwarn('No shelf number') unless $self->has_shelf_number;
    $self->copy_multipage_pdf if $self->is_thesis_workflow; 
}

sub config_any_args { { driver_args => { General => { '-UTF8' => 1 } } } }

sub execute {
    my ( $self, $opt, $args ) = @_;

    # you may ignore $opt, it's in the attributes anyway

    $self->make_mets;
    
}

__PACKAGE__->meta->make_immutable;
1;