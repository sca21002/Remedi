use utf8;
package Remedi::METS::App;

# ABSTRACT: Application class for command mets

use Moose;

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

__PACKAGE__->meta->make_immutable;

1;  