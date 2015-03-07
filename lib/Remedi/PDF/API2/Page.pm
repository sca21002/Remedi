package Remedi::PDF::API2::Page;

# ABSTRACT: Class for a page in PDF::API2 

use Moose;
use PDF::API2;
use MooseX::AttributeShortcuts;
use Remedi::PDF::API2::Image;
use namespace::autoclean;

has '_page' => (
    is => 'ro',
    isa => 'PDF::API2::Page',
    handles => [qw(
        get_cropbox cropbox get_mediabox mediabox gfx annotation text rotate
    )],
);

has 'images' => (
    traits => ['Array'],
    is => 'lazy', 
    isa => 'ArrayRef[Remedi::PDF::API2::Image]',
    handles => {
        all_images   => 'elements',
        count_images => 'count',
        sort_images  => 'sort', 
    }     
);

sub _build_images {
    my $self = shift;
    my $images;
    
    return unless exists $self->_page->{Resources};
    my $resources = $self->_page->{Resources};
    if (ref($resources) =~ /Objind$/) {
        $resources->realise;        # uncoverable statement
    }

    return unless exists $resources->{XObject};
    my $xobject = $resources->{XObject};
    if (ref($xobject) =~ /Objind$/) {
        $xobject->realise;          # uncoverable statement
    }

    my @keys = keys(%$xobject);
    foreach my $key (@keys) {
        next unless ref($xobject->{$key});
        if (ref($xobject->{$key}) =~ /Objind$/) {
            $xobject->{$key}->realise;    
        }
        next unless $xobject->{$key}->{Type}->can('val');     
        next unless $xobject->{$key}->{Type}->val eq 'XObject';
        next unless $xobject->{$key}->{Subtype}->can('val');     
        next unless $xobject->{$key}->{Subtype}->val eq 'Image';
        my $image = $xobject->{$key};
        push @$images, Remedi::PDF::API2::Image->new(key => $key, _image => $image);
    }
    return $images;
}

__PACKAGE__->meta->make_immutable; 

1;
