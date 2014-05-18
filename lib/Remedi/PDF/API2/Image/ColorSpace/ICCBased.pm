package Remedi::PDF::API2::Image::ColorSpace::ICCBased;

# ABSTRACT: Class for ICC colorSpace

use Moose;
use PDF::API2;
use MooseX::AttributeShortcuts;
use Remedi::Types::Remedi qw(PDFDict);
use namespace::autoclean;

extends qw( Remedi::PDF::API2::Image::ColorSpace );

has 'dict' => ( is => 'lazy', isa => PDFDict );

sub _build_dict {
    my $self = shift;
    
    my $dict = $self->_colorspace->val->[1];
    $dict->realise if ref($dict) =~ /Objind$/;
    return $dict;
}

sub _build_number_of_color_components {
    my $self = shift;
    
    my $N = $self->dict->{N};
    return $N->val;
}

__PACKAGE__->meta->make_immutable;

1;

