use utf8;
package Remedi::Singlepage::PDF::FromTIFF;

# ABSTRACT: PDF file with footer from TIFF source file

use Moose;
    extends qw( Remedi::Singlepage::PDF );

use namespace::autoclean;

    
sub _build_colortype { (shift)->image->colortype }

sub _build_cropbox {
    my $self = shift;
    
    return [@{$self->mediabox}];
}

sub _build_mediabox {
    my $self = shift;

    my $mediabox = [@{$self->image->mediabox}];
    $mediabox->[3] += $self->footer_height->{$self->size_class};
    return $mediabox;
}

sub _build_scaling_factor {
    my $self = shift;
    
    return 72 / $self->image->resolution;
}

sub import_source {
    my $self = shift;
    
    my $pdf_image_object = $self->colortype ne 'monochrome'
        ? $self->image_jpeg($self->image->jpeg->path)
        : $self->image_tiff($self->image->path);
    my $gfx = $self->page->gfx;
    $gfx->image($pdf_image_object,
                $self->mediabox->[0],
                $self->footer_height->{$self->size_class},
                $self->scaling_factor,
    );
}

# Bug #62287 for MooseX::UndefTolerant is not immutable-tolerant 
__PACKAGE__->meta->make_immutable;  

1; # Magic true value required at end of module
__END__