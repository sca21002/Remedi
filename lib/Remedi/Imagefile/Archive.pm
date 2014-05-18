use utf8;
package Remedi::Imagefile::Archive;

# ABSTRACT: Image file of type archive 

use Moose;
    extends qw(Remedi::Imagefile);

use Remedi::Units;
use Remedi::Types qw(
    Bool Dir File Imagefile ImagefileDestFormat ISIL Library_union_id Path
    PositiveInt ThumbnailFormat Usetype
);
use Path::Tiny;
use Remedi::ImageMagickCmds;
use namespace::autoclean;

with 'Remedi::Urn_nbn_de';

has 'dest_format' => (
    is => 'rw',
    isa => ImagefileDestFormat,   
    default => 'PDF',                
);

has 'sRGB' => ( isa => Imagefile, is => 'lazy' );
has 'jpeg' => ( isa => Imagefile, is => 'lazy' );

has 'isil'    =>  ( is => 'ro', isa => ISIL,       required  => 1 );
has 'library_union_id'=>( is => 'ro', isa => Library_union_id, required  => 1 );
has 'profile'       =>  ( is => 'ro', isa => Bool,             required  => 1 );
has '+regex_filestem_prefix' => ( required  => 1 );
has 'sRGB_profile' => ( is => 'ro', isa => File, coerce => 1,  predicate => 1 );
has 'thumbnail_format'=> ( is => 'ro', isa => ThumbnailFormat, predicate => 1 );
has 'thumbnail_width' => ( is => 'ro', isa => PositiveInt,     predicate => 1 );
has 'tempdir'         => ( is => 'lazy', isa => Dir );

has 'usetype' => (
    is => 'ro',
    isa => Usetype,
    default => 'archive',
);

sub _build_sRGB {
    my $self = shift;
    
    $self->log->logcroak( sprintf(
        "no sRGB profile found for converting '%s' to sRGB", $self->basename
    )) unless $self->has_sRGB_profile;
    $self->log->logcroak(
        'converting to sRGB only implemented for TIFF or JPEG files in color'
        . ' and profile is true: ' . $self->basename . ' Color: '
        . $self->colortype . ' Format: ' .  $self->format
        . ' Profil: ' . $self->profile
    ) if $self->colortype ne 'color' 
           or !($self->format eq 'TIFF' or $self->format eq 'JPEG')
           or not $self->profile;
    my $sRGB_file_obj = path($self->tempdir, 'sRGB.' . $self->suffix);
    my $sRGB_profile = $self->sRGB_profile;
    convert_image_in_profile(
        $self->path_abs_str, $sRGB_file_obj->absolute->stringify,
        $sRGB_profile,
    );
    Remedi::Imagefile->new(
        isil => $self->isil,
        library_union_id => $self->library_union_id,
        regex_filestem_prefix => $self->regex_filestem_prefix,       
        file => $sRGB_file_obj,
        profile => 0,
        regex_filestem_var => $self->regex_filestem_var,
        size_class_border => 150 * pt_pro_mm,
    );
}

sub _build_jpeg {
    my $self = shift;
    
    $self->log->logcroak(
      'converting to JPEG only implemented for TIFF files in color or grayscale'
    ) if $self->colortype eq 'monochrome' or $self->format ne 'TIFF';
    my $jpeg_file_obj = path($self->tempdir, 'tmp.jpg');
    $self->log->warn(
        'No conversion to sRGB colorspace for ' . $self->path_abs_str
    ) if $self->colortype eq 'color' and not $self->profile;    
    my $img = ($self->colortype eq 'color' and $self->profile)
              ? $self->sRGB : $self; 
    convert_tiff_to_jpeg(
        $img->path_abs_str,
        $jpeg_file_obj->absolute->stringify,
    );
    Remedi::Imagefile->new(
        isil => $self->isil,
        library_union_id => $self->library_union_id,
        regex_filestem_prefix => $self->regex_filestem_prefix,                   
        file => $jpeg_file_obj,
        profile => 0,
        regex_filestem_var => $self->regex_filestem_var,
        size_class_border => 150 * pt_pro_mm,
    );
}

sub _build_tempdir { Path::Tiny->tempdir() }

sub create_thumbnail {
    my $self = shift;
    my $dest_dir = shift;
    
    $self->log->logcroak( sprintf(
        "Attribute 'thumbnail_format' and 'thumbnail_width' required for"
        . "converting '%s' into thumbnail", $self->basename
    ) ) unless $self->has_thumbnail_format and $self->has_thumbnail_width;
    $self->log->warn('No conversion to sRGB colorspace for ' . $self->name)
        if $self->colortype eq 'color' and not $self->profile;        
    my $img = ($self->colortype eq 'color' and $self->profile)
              ? $self->sRGB : $self; 
    my $format = $self->thumbnail_format;
    my $thumbnail_file_obj = path(
        $dest_dir, $self->filestem . '.' . substr(lc $format,0,3)
    );
    my $width = $self->thumbnail_width;
    Remedi::ImageMagickCmds::create_thumbnail(
        $img->path_abs_str,
        $format,
        $thumbnail_file_obj->absolute->stringify,
        $width,
    );
}

sub get_niss {
    my $self = shift;

    my $niss = lc($self->filestem);
    $niss =~ s/_/-/g;
    $niss .= '-';
    return $niss;
}

__PACKAGE__->meta->make_immutable;

1; # Magic true value required at end of module
__END__
