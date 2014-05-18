use utf8;
package Remedi::Singlepage::TIFF;

# ABSTRACT: TIFF file with footer line 

use Moose;
    extends qw(Remedi::Singlepage);
    with    qw(MooseX::Log::Log4perl);
use Remedi::Units;
use Remedi::ImageMagickCmds;
use Remedi::Types qw( Bool Dir FontSize Path Word );
use Path::Tiny;
use namespace::autoclean;

has '+image' => (
    handles => [ qw( size_class resolution colortype) ]
);

has 'profile'         => ( is => 'ro', isa => Bool, required => 1 );
has 'tempdir'         => ( is => 'lazy', isa => Dir );

sub _build_logo_file {
    my $self = shift;
   
    my $size_class = $self->size_class;
    my $resolution = $self->resolution;
    my $logo_filename
        = $self->logo_file_prefix
          . $resolution . 'dpi_'
          . $self->footer_logo_file_infix->{$self->colortype}
          . '_'
          . sprintf("%.0f", $self->footer_logo_width->{$size_class} / pt_pro_mm)
          . '_'
          . sprintf("%.0f", $self->footer_height->{$size_class} / pt_pro_mm)
          . '.tif'
          ;
    return path( $self->logo_path, $logo_filename );
}

sub _build_logo_file_2 {
    my $self = shift;
   
    return unless $self->has_logo_file_prefix_2 and $self->has_logo_path_2;
    my $size_class = $self->size_class;
    my $resolution = $self->resolution;
    my $logo_filename
        = $self->logo_file_prefix_2
          . $resolution . 'dpi_'
          . $self->footer_logo_file_infix->{$self->colortype}
          . '_'
          . sprintf("%.0f", $self->footer_logo_width->{$size_class} / pt_pro_mm)
          . '_'
          . sprintf("%.0f", $self->footer_height->{$size_class} / pt_pro_mm)
          . '.tif'
          ;
    return path( $self->logo_path_2, $logo_filename );
}

sub _build_tempdir { Path::Tiny->tempdir() }

sub create_footer {
    my $self = shift;
    my $dest_dir = shift;
   
       
    my $image = $self->image;
    $self->log->logdie("Wrong destination format '" . $image->dest_format .
        "' for '" . $image->file . "', only TIFF useful")
        unless $image->dest_format eq 'TIFF';
    my $dest_format = $image->dest_format;
    
    my $urn_file = path( $self->tempdir, 'urn.tif' )->stringify;
    my $background_color = $self->footer_background->{$image->colortype};
    my $color            = $self->footer_color->{$image->colortype}; 
    text_to_tiff( $image->urn, $urn_file,
        {   font_size        => $self->urn_font_size,
            # font_type        => 'Humnst777-BT-Roman',
            font_type        => $self->urn_font_type,
            background_color => $background_color,
            resolution       => $image->resolution,
        }
    );
    my $logo_filename = $self->logo_file->stringify;
    my $footer_filename = path( $self->tempdir, 'footer.tif' )->stringify;
    my $footer_height_px = sprintf(
        "%.0f",
        $self->footer_height->{$image->size_class} / 72 * $image->resolution
    );
    combine_logo( $logo_filename, $footer_filename,
        {   resolution => $image->resolution,
            image_width_px   => $image->width_px,
            footer_height_px => $footer_height_px,
            background_color => $background_color,
            logo_file_2 => $self->logo_file_2,
        }
    );    
    if ($self->urn_level eq 'single_page') {
        combine_urn( $footer_filename, $urn_file, $footer_filename,
            {   logo_width => $self->footer_logo_width->{$image->size_class},
            resolution => $image->resolution,
            logo_file_2 => $self->logo_file_2,
            }
        );
    }       
    my $footerln_filename = path( $self->tempdir, 'footerln.tif' )->stringify;
    add_separation_line ( $footer_filename, $footerln_filename,
        {   image_width_px   => $image->width_px,
            background_color => $background_color,
            color            => $color,
        }
    );
    $self->log->warn('No conversion to sRGB colorspace for ' . $image->path)
        if $image->colortype eq 'color' and not $self->profile;
    my $image_mod = ($image->colortype eq 'color' and $self->profile)
                    ? $image->sRGB : $image;
    my $dest_filename = path(
        $dest_dir, $image->filestem . '.' . lc( substr($dest_format,0,3) )
    )->stringify;
    add_footer_to_image (
        $image_mod->path_abs_str, $footerln_filename, $dest_filename,
        {   dest_format => $dest_format,
            resolution  => $image->resolution,
        }
    );    
}

# Bug #62287 for MooseX::UndefTolerant is not immutable-tolerant 
__PACKAGE__->meta->make_immutable;

1; # Magic true value required at end of module
__END__


=attr image

Scan file
Used to get informations like original size, color type, filename

=attr profile

If set images are converted into the C<standard RGB color space> (sRGB) 

=attr tempdir

A temporary directory

