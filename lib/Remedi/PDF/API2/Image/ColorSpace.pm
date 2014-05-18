package Remedi::PDF::API2::Image::ColorSpace;

# ABSTRACT: Basic colorspace class

use Moose;
use PDF::API2;
use MooseX::AttributeShortcuts;
use namespace::autoclean;

has '_colorspace' => (
    is => 'ro',
    isa => 'PDF::API2::Basic::PDF::Objind',
    required => 1,
);

has 'number_of_color_components' => ( is => 'lazy', isa => 'Int' );

__PACKAGE__->meta->make_immutable;

1;
