package Remedi::PDF::API2::Image;

# ABSTRACT: Image class for PDF::API2 

use Moose;
use Remedi::PDF::API2::Image::ColorSpace::CreateInstance;
use Remedi::Types qw(PDFDict Int Str);
use MooseX::AttributeShortcuts;
use namespace::autoclean;

use MooseX::Types -declare => [ qw(ColorSpace) ];

class_type ColorSpace, { class => 'Remedi::PDF::API2::Image::ColorSpace' };

has 'key'        => ( is => 'ro',   isa => Str );

has '_image'     => ( is => 'ro',   isa => PDFDict, required => 1 );


has 'area'       => ( is => 'lazy', isa => Int );
has 'colorspace' => ( is => 'lazy', isa => ColorSpace );

has 'bits_per_components' => ( is => 'lazy', isa => Int );
has 'height'              => ( is => 'lazy', isa => Int );
has 'width'               => ( is => 'lazy', isa => Int );


sub _build_area {
    my $self = shift;

    return $self->height * $self->width;
}


sub _build_colorspace {
    my $self = shift;
    
    return unless exists $self->_image->{ColorSpace};
    return Remedi::PDF::API2::Image::ColorSpace::CreateInstance->new(
        _colorspace => $self->_image->{ColorSpace},    
    )->new_colorspace();                                                          
}

sub _build_bits_per_components {
    my $self = shift;
    
    exists $self->_image->{BitsPerComponent}
    && $self->_image->{BitsPerComponent}->can('val')
    && $self->_image->{BitsPerComponent}->val;
}

sub _build_height {
    my $self = shift;
    
    exists $self->_image->{Height}
    && $self->_image->{Height}->can('val')
    && $self->_image->{Height}->val;
}

sub _build_width {
    my $self = shift;
    
    exists $self->_image->{Width}
    && $self->_image->{Width}->can('val')
    && $self->_image->{Width}->val;
}

__PACKAGE__->meta->make_immutable;

1;
