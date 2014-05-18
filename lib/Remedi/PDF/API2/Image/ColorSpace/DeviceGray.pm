package Remedi::PDF::API2::Image::ColorSpace::DeviceGray;

# ABSTRACT: Class for 8 bit (gray) colorSpace

use Moose;
use PDF::API2;
use namespace::autoclean;

extends qw( Remedi::PDF::API2::Image::ColorSpace );

sub _build_number_of_color_components { 1 }

__PACKAGE__->meta->make_immutable;

1;

