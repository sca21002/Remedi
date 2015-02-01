use utf8;
package Remedi::DigiFooter::App;

# ABSTRACT: Application class for command digifooter

use Moose;

with qw(
    Remedi         
    Remedi::DigiFooter 
    MooseX::SimpleConfig
    MooseX::Getopt
    MooseX::Log::Log4perl
);
    
sub BUILD {
    my $self = shift;
    
    $self->init_logging(@_);
    $self->log->logcroak(
        'jpeg2000list must be given when dest_format_key = list'
    ) if $self->dest_format_key eq 'list' && ! $self->has_jpeg2000list;
}

use namespace::autoclean;

__PACKAGE__->meta->make_immutable;

1;  
