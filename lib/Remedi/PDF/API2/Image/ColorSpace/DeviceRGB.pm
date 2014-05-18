package Remedi::PDF::API2::Image::ColorSpace::DeviceRGB;

# ABSTRACT: Class for 24 bit (color) colorSpace

use Moose;
use PDF::API2;
use namespace::autoclean;

extends qw( Remedi::PDF::API2::Image::ColorSpace );

sub _build_number_of_color_components { 3 }

__PACKAGE__->meta->make_immutable;

1;

