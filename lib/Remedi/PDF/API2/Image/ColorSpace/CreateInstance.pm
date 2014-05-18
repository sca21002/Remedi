package Remedi::PDF::API2::Image::ColorSpace::CreateInstance;

# ABSTRACT: Class ColorSpace::CreateInstance

use Moose;
use Moose::Util::TypeConstraints qw(enum);
use Modern::Perl;
use PDF::API2;
use MooseX::AttributeShortcuts;
use MooseX::Types::LoadableClass qw(LoadableClass);
extends qw( Remedi::PDF::API2::Image::ColorSpace );
use namespace::autoclean;

use MooseX::Types -declare => [ qw(ColorSpaceType) ];

subtype ColorSpaceType,
        as enum( [qw( Indexed ICCBased DeviceGray DeviceRGB )] ),
        message { "'$_' is not a known ColorSpace" };

has 'class' => ( is => 'lazy', isa => LoadableClass, coerce => 1 );

has 'colorspacetype' => ( is => 'lazy', isa => ColorSpaceType );

sub new_colorspace {
    my $self = shift;
    
    $self->class->new(_colorspace => $self->_colorspace);
}

sub _build_colorspacetype {
    my $self = shift;
    
    my $colorspace_obj =$self->_colorspace;
    if ( ref($colorspace_obj) =~ /Objind$/ ) {
        $colorspace_obj->realise;
    }
    my $type;
    if ( ref($colorspace_obj) =~ /Array$/ ) {
        my $colorspace_arr
            = $colorspace_obj->can('val') && $colorspace_obj->val;
        $type = $colorspace_arr->[0]
                   && $colorspace_arr->[0]->can('val')
                   && $colorspace_arr->[0]->val;
    }
    elsif (ref($colorspace_obj) =~ /Name$/) {
        $type = $colorspace_obj->can('val') && $colorspace_obj->val;
    }
    else {
        # uncoverable statement until I find a corrupt PDF
        confess 'No Colorspace found';   
    }
    return $type;
}

sub _build_class {
    'Remedi::PDF::API2::Image::ColorSpace::'. shift->colorspacetype;    
}

__PACKAGE__->meta->make_immutable;

1;
