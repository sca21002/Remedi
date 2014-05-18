use utf8;
package Remedi::Imagefile;

# ABSTRACT: Base class for a image

use Moose;
    extends qw(Remedi::RemediFile);
   
use Moose::Util::TypeConstraints;               # for enum()
use MooseX::AttributeShortcuts;
use Remedi::Types qw(
    ArrayRef Colortype ImageExifTool ImageSizeClass Int Maybe Num Str
);
use Remedi::Units;
use Path::Tiny;
use Image::ExifTool;
use Data::Dumper;
use namespace::autoclean;

my %BITSPERSAMPLE_COLORTYPE_MAP = (
    '1'       =>  'monochrome', 
    '8'       =>  'grayscale',  
    '8 8 8'   =>  'color',
    '8, 8, 8' =>  'color',     
);

my %SUFFIX_FORMAT_MAP = (
    'pdf'  => 'PDF',
    'jpg'  => 'JPEG',
    'png'  => 'PNG',
    'tif'  => 'TIFF',
    'tiff' => 'TIFF',
    'gif'  => 'GIF',
    'jp2'  => 'JP2',
);

my %UNIT_INCH_MAP = (
    'inches' => 1,
    'cm'     => 1 / 2.54,
);

has 'colortype'   => ( is => 'lazy', isa => Colortype );

has 'exiftool'    => ( is => 'lazy', isa => ImageExifTool,  
                       handles => [ qw(GetInfo) ] );  

has 'format'      => ( is => 'lazy', isa => enum([values %SUFFIX_FORMAT_MAP]) );

has 'height_mm'   => ( is => 'lazy', isa => Num ); 

has 'height_px'   => ( is => 'lazy', isa => Int );

has 'icc_profile' => ( is => 'lazy', isa => Maybe[Str] );

has 'mediabox'    => ( is => 'lazy', isa => ArrayRef[Num] ); 

has resolution    => ( is => 'lazy', isa => Int );

has 'size_class'  => ( is => 'lazy', isa => ImageSizeClass ); 

has 'size_class_border' => ( is => 'ro', isa => Num, required => 1 ); 

has 'suffix'      => ( is => 'lazy', isa => Str );

has 'width_mm'    => ( is => 'lazy', isa => Num );

has 'width_px'    => ( is => 'lazy', isa => Int ); 

sub BUILD {
    shift->format;   # check supported imagefile format
}

sub _build_colortype {
    my $self = shift;
        
    my ($colortype, $bps, $clrcmp);
    my $pathstr = $self->path_abs_str;
    my $log     = $self->log;
    my $info = $self->GetInfo('BitsPerSample', { Group0 => ['EXIF'] } );
    _strips_the_embedded_instance_number($info);
    if (my $bps = $info->{BitsPerSample}) {
        $colortype = _get_colortype_from_bitspersample($bps)
            or $log->croak("Unknown Value '" . $bps . "' in file " . $pathstr);        
    } else {
        my $info = $self->GetInfo(
            'BitsPerSample', 'ColorComponents', { Group0 => ['File'] }
        );
        _strips_the_embedded_instance_number($info);
        my ($bps, $clrcmp) = @{$info}{ qw(BitsPerSample ColorComponents) };
        $log->croak("BitsPerSample not found for $pathstr") unless $bps;
        $log->croak("ColorComponents not found for $pathstr") unless $clrcmp;        
        $colortype = $bps == 1 && $clrcmp == 1 ? 'monochrome'
                   : $bps == 8 && $clrcmp == 1 ? 'grayscale'
                   : $bps == 8 && $clrcmp == 3 ? 'color'
                   : '';
        $log->croak("Colortype not identified for $pathstr with BitsPerSample: "
                 . "$bps and ColorComponents: $clrcmp") unless $colortype;
    }
    return $colortype;
}

sub _build_exiftool {
    my $self = shift;
    
    my $exiftool = new Image::ExifTool;
    $self->log->trace('Path: ' .  Dumper($self->path_abs_str));
    $exiftool->ExtractInfo( $self->path_abs_str );
    return $exiftool;
}


sub _build_format {
    my $self = shift;
    
    my $format = _get_format_from_suffix($self->suffix)
        or $self->log->logcroak(
            sprintf( "Unknown image file format '%s' for '%s'",
                     $self->suffix, $self->path_abs_str
        ));
    return $format;
}

sub _build_height_mm { 
    my $self = shift;
  
    return sprintf("%.1f", $self->height_px / $self->resolution * 25.4);
}

sub _build_height_px {
    my $self = shift;
    
    my $info = $self->GetInfo('ImageHeight', { Group0 => ['EXIF', 'File'] } );
    _strips_the_embedded_instance_number($info);
    return $info->{ImageHeight};    
}

sub _build_icc_profile {
    my $self = shift;
    
    my $info = $self->GetInfo( { Group0 => ['ICC_Profile'] } );
    return unless %$info;
    return $info->{ProfileDescription} || 'no description';
}

sub _build_mediabox {
    my $self = shift;
    
    return [
        0, 0,
        sprintf("%.0f", $self->width_px  * 72 / $self->resolution), 
        sprintf("%.0f", $self->height_px * 72 / $self->resolution)
    ];
}

sub _build_resolution {
    my $self = shift;
    
    my $info = $self->GetInfo(
        'XResolution', 'YResolution', 'ResolutionUnit',
        { Group0 => ['EXIF', 'JFIF'] },
    );
    _strips_the_embedded_instance_number($info);
    if ($info->{ResolutionUnit} eq 'None') {
        $info->{ResolutionUnit} = 'inches';
        $self->log->logcarp('ResolutionUnit None, assuming inches');
    }
    my $factor = _get_conversion_to_inch_factor( $info->{ResolutionUnit} )
        or $self->log->logcroak(
            ( $info->{ResolutionUnit}
                ? 'Unknown ResolutionUnit ' . $info->{ResolutionUnit}
                : 'Missing ResolutionUnit '
            ) . " for " 
            . $self->path_abs_str
        );     
    # rounded resolutions
    my $XResolution = sprintf("%.0f", $info->{XResolution} * $factor );
    my $YResolution = sprintf("%.0f", $info->{YResolution} * $factor );
    return $XResolution;
}

sub _build_size_class {
    my $self = shift;

    my $page_width = $self->width_px / $self->resolution * pt_pro_inch;    
    return  ($page_width > $self->size_class_border)
        ? 'large' : 'small';   
}

sub _build_suffix {
    my $self = shift;

    my ($suffix) = $self->basename =~ qr/.*\.([^.]*)$/;
    return $suffix; 
}

sub _build_width_mm { 
    my $self = shift;
  
    return sprintf("%.1f", $self->width_px / $self->resolution * 25.4);
}

sub _build_width_px {
    my $self = shift;
    
    my $info = $self->GetInfo('ImageWidth', { Group0 => ['EXIF', 'File'] } );
    _strips_the_embedded_instance_number($info);
    return $info->{ImageWidth};    
}

sub _get_colortype_from_bitspersample { $BITSPERSAMPLE_COLORTYPE_MAP{$_[0]} };

sub _get_format_from_suffix { $SUFFIX_FORMAT_MAP{lc $_[0]} };

sub _get_conversion_to_inch_factor { $_[0] ? $UNIT_INCH_MAP{$_[0]} : 0 }; 

sub _strips_the_embedded_instance_number {
    my $info = shift;
    
    #while ( my($key, $value) = each %$info ) {
    #    delete $info->{$key};
    #    my $key_new = Image::ExifTool::GetTagName($key);
    #    $info->{$key_new} = $value;
    #}
    
    return {map { Image::ExifTool::GetTagName($_) => $info->{$_} } keys %$info }
    
}

__PACKAGE__->meta->make_immutable;

1; # Magic true value required at end of module
__END__