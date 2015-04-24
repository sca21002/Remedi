package Remedi::ImageMagickCmds;

# ABSTRACT: Functions for manipulating images with ImageMagick

use strict;
use warnings;

use base 'Exporter';
use English qw( -no_match_vars );
use Readonly;
use Log::Log4perl;
use IO::CaptureOutput qw(capture_exec);

# Readonly my $QUOTE => $OSNAME eq 'MSWin32' ? q{"} : q{};
Readonly my $QUOTE => $OSNAME eq 'MSWin32' ? q{} : q{};


our @EXPORT    = qw(
    add_footer_to_image
    add_separation_line
    combine_logo
    combine_urn
    convert_tiff_to_jpeg
    convert_image_in_profile
    convert_tiff16_to_tiff8
    text_to_tiff
);

our @EXPORT_OK = qw();

sub add_footer_to_image {
    my $image_filename = shift;
    my $footer_filename = shift;
    my $dest_filename = shift;
    my $arg = shift;
    
    my $dest_format = $arg->{dest_format};
    my $resolution  = $arg->{resolution};
    my $compression_quality = $arg->{compression_quality} || 80;
    my $logger = Log::Log4perl->get_logger();
    
    $logger->logdie(
        "'$dest_format' not supported, only destination format TIFF or JPEG" .
        ' is supported so far'
    ) unless grep {/$dest_format/} qw(TIFF JPEG);
   
    my $options = [
        $QUOTE . $image_filename . $QUOTE,
        $QUOTE . $footer_filename . $QUOTE,
        '-append',   
        '-density',   $resolution . 'x' . $resolution,
        '-units',  'PixelsPerInch',
        '-depth', 8,
    ];
    if ($dest_format eq 'JPEG') {
        push @$options,  '-quality', $compression_quality;
    }                     
    $logger->debug(" ...combining to $dest_format output file");
    _im_cmd('convert', $options, $dest_format . ':' . $dest_filename);
}

sub add_separation_line {
    my $footer_filename = shift;
    my $footerln_file = shift;
    my $arg = shift;
    
    my $background_color = $arg->{background_color};
    my $color = $arg->{color};
    my $image_width_px = $arg->{image_width_px};
    my $logger = Log::Log4perl->get_logger();
    
    my $options =  [
        $QUOTE . $footer_filename . $QUOTE,
        '+antialias',
        '-fill', $background_color,
        '-stroke', $color,
        '-strokewidth',  2,
        '-draw', 'line 0,0,' . $image_width_px . ',0',
        '-alpha', 'Off',
        '-depth', 8,
    ];
    
    $logger->debug(" ...drawing separation line"); 
    _im_cmd('convert', $options, $footerln_file);
}

sub combine_logo {
    my $logo_filename = shift;
    my $footer_filename = shift;
    my $arg = shift;
    
    my $resolution = $arg->{resolution};
    my $image_width_px = $arg->{image_width_px};
    my $footer_height_px = $arg->{footer_height_px};
    my $background_color = $arg->{background_color};
    my $add_logo = $arg->{logo_file_2};
    my $logger = Log::Log4perl->get_logger();
    

    my $option_str = [
        '-size', $image_width_px . 'x' . $footer_height_px,
        "xc:$background_color",
        $QUOTE .  $logo_filename . $QUOTE,
        '-composite',
    ];        
    if ($add_logo) {
        push @$option_str, (
            $QUOTE . $add_logo . $QUOTE,
            '-gravity', 'East',
            '-composite',
        );
    }
    push @$option_str, (                
        '-density',  $resolution . 'x' . $resolution,
        '-units', 'PixelsPerInch',
        '-depth', 8,
    );
    $logger->debug(" ...combining with logo");  
    _im_cmd('convert', $option_str, $footer_filename);
}

sub combine_urn {
    my $footer_filename = shift;
    my $urn_filename  = shift;
    my $footer_urn_filename = shift;
    my $arg = shift;
    
    my $logo_width = $arg->{logo_width};
    my $resolution = $arg->{resolution};
    my $add_logo = $arg->{logo_file_2};
    my $logger = Log::Log4perl->get_logger();
    

    my $half_logo_width_px = sprintf(
        "%.0f", $logo_width / 72 * $resolution / 2
    );
    my $option_str = [
        $QUOTE . $footer_filename . $QUOTE,
        $QUOTE . $urn_filename . $QUOTE,
        '-gravity', 'Center',
        '-geometry',
        ($add_logo ? '+0' : '+' . $half_logo_width_px)
            . '+0',
        '-composite',
    ];        
    push @$option_str, (                
        '-density',  $resolution . 'x' . $resolution,
        '-units', 'PixelsPerInch',
        '-depth', 8,
    );
    $logger->debug(" ...combining with urn");  
    _im_cmd('convert', $option_str, $footer_urn_filename);
}



sub convert_tiff_to_jpeg {
    my $tiff_filename = shift;
    my $jpeg_filename = shift;
    my $arg = shift;
    
    my $quality = $arg->{quality} || 50;
    my $logger = Log::Log4perl->get_logger();
    
    my $options = [
        $QUOTE . $tiff_filename . $QUOTE,
        '-quality',  $quality,
        '-depth', 8,
    ];
    $logger->debug(" ...converting from tiff to jpeg");
    _im_cmd('convert', $options, $jpeg_filename);
    return;
}



sub convert_image_in_profile {
    my $source_filename = shift;
    my $dest_filename = shift;
    my $profile = shift;
 
    my $logger = Log::Log4perl->get_logger();
    my $options = [
        $QUOTE . $source_filename . $QUOTE,
        '-profile', $QUOTE . $profile . $QUOTE,
        '-depth', 8,
    ];
    $logger->debug(" ...converting image in profile");
    _im_cmd('convert', $options, $dest_filename);
}

sub convert_tiff16_to_tiff8 {
    my $source_tiff_filename = shift;
    my $dest_tiff_filename = shift;

    my $logger = Log::Log4perl->get_logger();
    my $options = [
        $QUOTE . $source_tiff_filename . $QUOTE,
        '-depth', 8,
    ];
    $logger->debug(" ...converting from 16bit to 8bit TIFF");
    _im_cmd('convert', $options, $dest_tiff_filename);
}

sub convert_to_tiff_g4_with_resample {
    my $source_tiff_filename = shift;
    my $dest_tiff_filename = shift;
    my $resolution = shift;
    
    my $logger = Log::Log4perl->get_logger();
    my $options = [
        $QUOTE . $source_tiff_filename . $QUOTE,
        '-resample',  $resolution,
        '-colors', 2,
        '-colorspace',  'gray',
        '-compress',  'group4',
    ];
    $logger->debug(" ...converting to TIFF G4");
    _im_cmd('convert', $options, $dest_tiff_filename);    
}    


sub create_thumbnail {
    my $img_filename = shift; 
    my $format = shift;
    my $thumb_name = shift;
    my $height = shift;

    my $logger = Log::Log4perl->get_logger();
    $logger->logdie("Param img_filename missing for create_thumbnail")
        unless $img_filename;
    $logger->logdie("Param format missing for create_thumbnail")
        unless $format;
    $logger->logdie("Param thumb_name missing for create_thumbnail")
        unless $thumb_name;
    $logger->logdie("Param height missing for create_thumbnail")
        unless $height;
    my $thumbnail_filename = $format . ':' . $thumb_name;
    my $options = [
        $QUOTE . $img_filename . $QUOTE,
        '-thumbnail', 'x' . $height, 
        '-quality', 95,
    ];
    $logger->debug(" ...creating thumbnail");
    _im_cmd('convert', $options, $thumbnail_filename);
}

sub text_to_tiff {
    my $text = shift;
    my $tiff_filename = shift;
    my $arg = shift;
    
    my $logger = Log::Log4perl->get_logger();
    my $font_size = $arg->{font_size} or
        $logger->logdie('no font_size given for text_to_tiff');
    my $font_type = $arg->{font_type} or
        $logger->logdie('no font_type given for text_to_tiff');
    my $background_color = $arg->{background_color} or
        $logger->logdie('no background_color given for text_to_tiff');
    my $resolution = $arg->{resolution} or
        $logger->logdie('no resolution given for text_to_tiff');

    my @background =  ($background_color ne 'white')
                ? ('-background', $background_color)
                : ('-monochrome')
                ;
    my $options = [
        '-density', $resolution . 'x' . $resolution,
        '-units', 'PixelsPerInch',
        @background,
        '-font',  $font_type,
        '-pointsize', $font_size,
        "label:$text",
        '-alpha', 'Off',
        '-depth', 8,
    ];
    _im_cmd('convert', $options, $tiff_filename);
}

sub _im_cmd {
   my $cmd = shift;
   my $options = shift;
   my $outfile = shift;
   
   my @args = ( $cmd, @$options, $QUOTE . $outfile . $QUOTE );
   my $logger = Log::Log4perl->get_logger();
   $logger->trace("Systemaufruf: @args");
   my ($stdout, $stderr, $success, $exit_code) = capture_exec(@args);
   $stderr =~ s/^.*Incompatible type for "RichTIFFIPTC".*$(?:\s*)//m;
   $logger->trace("$cmd STDOUT: $stdout") if $stdout;
   $logger->trace("$cmd STDERR: $stderr") if $stderr;
   $logger->logdie("system @args failed: $?") unless $success;
   $logger->trace("Aufruf erfolgreich beendet");     
}


1; # Magic true value required at end of module
__END__
