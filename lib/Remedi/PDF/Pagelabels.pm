use utf8;
package Remedi::PDF::Pagelabels;

# ABSTRACT: Class for a group of pagelabels in PDF::API2 

use Moose;
use MooseX::AttributeShortcuts;
use aliased 'Remedi::PDF::Pagelabel';
use Remedi::Types qw(ArrayRef PositiveInt);
use Roman;
use namespace::autoclean;
use Data::Dumper;

has '_pagelabels' => (
    traits  => ['Array'],
    is      => 'ro',
    isa     => ArrayRef[Pagelabel],
    default => sub { [] },
    handles => {
        all     => 'elements',
        add      => 'push',
        map     => 'map',
        filter  => 'grep',
        find     => 'first',
        get      => 'get',
        join   => 'join',
        count   => 'count',
        has_pagelabels     => 'count',
        has_no_pagelabels  => 'is_empty',
        sorted => 'sort',
    },
);

has 'number_of_pages' => ( is => 'ro', isa => PositiveInt, required => 1 );

=method

=cut 

sub sequence {
    my $self = shift;
    
    my @sequence;
    my $label_index_max = $self->count - 1;
    for (my $i = 0; $i <= $label_index_max; $i++) {
        
        my $pagelabel = $self->get($i);
        
        last if $pagelabel->start > $self->number_of_pages - 1; 
        
        my $index_max  = ($i == $label_index_max)             # last pagelabel?
            ? $self->number_of_pages -1    # last page of pdf if last pagelabel 
            : ($self->get($i+1)->page_no >= $self->number_of_pages) # too far?
            ? $self->number_of_pages -1    # last page of pdf  
            : $self->get($i+1)->page_no -1 # else to last page before next label
                                           # page_no is zero-based
        ;                                  
        push @sequence, $self->sequence_part($pagelabel, $index_max);
    }
    return \@sequence;
}    


sub sequence_part {
    my ($self, $pagelabel, $index_max) = @_;
   
    my ($page_no, $style, $prefix, $start) = (
        $pagelabel->page_no,
        $pagelabel->style,
        $pagelabel->prefix,
        $pagelabel->start
    );
    my %func_map = (
        ''      => sub {''},
        decimal => sub { shift },
        Roman   => \&Roman,
        roman   => \&roman,
        alpha   => \&alpha,
        Alpha   => \&Alpha, 
    );
    return calculate_sequence(
        $start,
        $index_max - $page_no + $start,    
        $func_map{$style},
        $prefix,
    );   
};

sub calculate_sequence {
    my ($start, $end, $func, $prefix) = @_;
    
    return map { $prefix . $func->($_) } $start .. $end; 
}

sub alpha { ('a' .. 'z')[ $_[0] % 26 -1] x ( int( ($_[0] - 1) / 26 ) + 1 ) }

sub Alpha { uc alpha $_[0] } 

__PACKAGE__->meta->make_immutable;
1;