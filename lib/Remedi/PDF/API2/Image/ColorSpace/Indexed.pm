package Remedi::PDF::API2::Image::ColorSpace::Indexed;

# ABSTRACT: Class for indexed colorSpace

use Moose;
use PDF::API2;
use MooseX::AttributeShortcuts;
use namespace::autoclean;


extends qw( Remedi::PDF::API2::Image::ColorSpace );

has 'dict' => ( is => 'lazy', isa => 'PDF::API2::Basic::PDF::Array' );

has 'base_colorspace' => ( is => 'lazy', isa => 'Any' );

sub _build_dict {
    my $self = shift;
    
    my $dict = $self->_colorspace->val->[1];
    $dict->realise if ref($dict) =~ /Objind$/;
    return $dict;
}

sub _build_base_colorspace {
    my $self = shift;
    
    return Remedi::PDF::API2::Image::ColorSpace::CreateInstance->new(
        _colorspace => $self->dict,    
    )->new_colorspace();     
}

sub _build_number_of_color_components {
    (shift)->base_colorspace->number_of_color_components;
}

__PACKAGE__->meta->make_immutable;

1;