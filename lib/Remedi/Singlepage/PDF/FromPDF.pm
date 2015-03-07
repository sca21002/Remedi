use utf8;
package Remedi::Singlepage::PDF::FromPDF;

# ABSTRACT: PDF file with footer from multi-page PDF file

use Moose;
    extends qw( Remedi::Singlepage::PDF );

use Remedi::Types qw(
    ArrayRef Num PositiveNum RemediPdfApi2 RemediPdfApi2Page Int Word
);
use Try::Tiny;
use namespace::autoclean;


has 'deviation_width_height_tolerance_percent' => (
    is => 'ro',
    isa => PositiveNum,
    required => 1,
);

has 'fixed_scaling_factors' => (
    is => 'ro',
    isa => ArrayRef[Num],
    default => sub{ [ 1, 300/400, 300/513, 0.5, 300/644, 300/767] }
);

has 'resolution_correction' => ( is => 'ro', isa => Num, predicate => 1 );

has 'scaling_factor_tolerance_percent' => (
    is => 'ro',
    isa => PositiveNum,
    required => 1,
);

has 'source_pdf' => ( is => 'rw', isa => RemediPdfApi2, required => 1 );

has 'source_pdf_page' => ( is => 'lazy', isa => RemediPdfApi2Page);

has 'source_pdf_page_num' => ( is => 'lazy', isa => Int, predicate => 1 );

has 'logo_file_prefix_3' => ( is => 'ro', isa => Word, predicate => 1 );

sub _build_colortype {
    my $self = shift;

    my $colortype;
    try {
        my $images = $self->source_pdf_page->images;
        my $image_count = scalar @$images;
        $self->log->info($image_count . ' images rather than 1 in the PDF page')
        if $image_count > 1;
        my $image = $images->[0];
    
        my $ncc = $image->colorspace->number_of_color_components;
        my $bpc = $image->bits_per_components;
        $colortype = $ncc == 1 && $bpc == 1 ? 'monochrome'
                   : $ncc == 1 && $bpc == 8 ? 'grayscale'
                   : $ncc == 3 && $bpc == 8 ? 'color'
                   : undef
                   ;
        $self->log->logcroak('Unknown colortype with bits per components = '
        . $bpc . ' and number of color components = ' . $ncc) unless $colortype; 
        $self->log->debug('Colortype ' . $colortype);
    } catch {
        $self->log->warn("Looking for colortype ended with error: $_\n"
            . "Arbitrarily setting colortype = color as the savest guess." );
        $colortype = 'color';
    };
    return $colortype;
}

sub _build_cropbox {
    my $self = shift;
    
    my @source_cropbox = $self->source_pdf_page->get_cropbox;
    $self->log->trace(
        $self->_print_pdf_page_box( \@source_cropbox, 'Quell-Cropbox' )
    );
    $self->log->trace('Seite wird gedreht') if $self->do_rotate;    
    my @dest_cropbox
        = $self->do_rotate ? @source_cropbox[1,0,3,2] : @source_cropbox;    
    @dest_cropbox = map { $_ * $self->scaling_factor } @dest_cropbox;
    $dest_cropbox[3] += $self->footer_height->{$self->size_class};
    $dest_cropbox[3] += $self->footer_height->{$self->size_class}
        if $self->with_logo_3;
    $self->log->trace( $self->_print_pdf_page_box(
        \@dest_cropbox, 'cropbox of destination pdf'
    ) );
    return \@dest_cropbox;
}

sub _build_fixed_scaling_factors {
    my $self = shift;
    
    my $tolerance = $self->scaling_factor_tolerance_percent;
    my @fixed_values = ( 1, 300/400, 0.5, 300/644 );
    
    my @factors = map {
        {
            lower => $_ *  (1 - $tolerance/100),
            upper => $_ *  (1 + $tolerance/100),
            fixed => $_,
        }                
    } @fixed_values; 
    return \@factors;
}

sub _build_mediabox {
    my $self = shift;
    
    my @source_mediabox = $self->source_pdf_page->get_mediabox;
    $self->log->trace(
        $self->_print_pdf_page_box( \@source_mediabox, 'Quell-Mediabox' )
    );
    $self->log->trace('Seite wird gedreht') if $self->do_rotate;
    my @dest_mediabox
        = $self->do_rotate ? @source_mediabox[1,0,3,2] : @source_mediabox;
    
    @dest_mediabox = map { $_ * $self->scaling_factor } @dest_mediabox;
    $dest_mediabox[3] += $self->footer_height->{$self->size_class};
    $dest_mediabox[3] += $self->footer_height->{$self->size_class}
        if $self->with_logo_3;    
    $self->log->trace( $self->_print_pdf_page_box(
        \@dest_mediabox, 'Mediabox of destination pdf'
    ) );
    return \@dest_mediabox;
}

sub _build_scaling_factor {
    my $self = shift;
    
    my $image_width_mm  = $self->image->width_mm;
    my $image_height_mm = $self->image->height_mm;
    my $source_mediabox = [$self->source_pdf_page->get_mediabox];
    my $source_cropbox = [$self->source_pdf_page->get_cropbox];
    my $width_height_tol = $self->deviation_width_height_tolerance_percent;
    my $tol = $self->scaling_factor_tolerance_percent;
    
    my $fixed_factors = $self->fixed_scaling_factors;
    my $pdf_height_mm
        = ($source_mediabox->[3] - $source_mediabox->[1]) * 25.4/72;
    my $pdf_width_mm
        = ($source_mediabox->[2] - $source_mediabox->[0]) * 25.4/72;
    my $pdf_height_crop_mm
        = ($source_cropbox->[3] - $source_cropbox->[1]) * 25.4/72;
    my $pdf_width_crop_mm
        = ($source_cropbox->[2] - $source_cropbox->[0]) * 25.4/72;
    $self->log->trace(
          "\n  Hoehe (PDF) [mm]: " . sprintf("%.1f", $pdf_height_mm)
        . "\n  Breite (PDF) [mm]: " . sprintf("%.1f", $pdf_width_mm)
        . "\n  Hoehe (PDF crop) [mm]: " . sprintf("%.1f", $pdf_height_crop_mm)
        . "\n  Breite (PDF crop) [mm]: " . sprintf("%.1f", $pdf_width_crop_mm)        
        . "\n  Hoehe (TIFF) [mm]: " . $image_height_mm
        . "\n  Breite (TIFF) [mm]: " . $image_width_mm
    );
    my $scaling_factor_width = $image_width_mm / $pdf_width_mm;
    my $scaling_factor_height = $image_height_mm / $pdf_height_mm;
    my $deviation_width_height_percent_save =
        my $deviation_width_height_percent =
            abs($scaling_factor_height - $scaling_factor_width)
            / $scaling_factor_width * 100
    ;
    # test for a rotated image
    if ($deviation_width_height_percent > $width_height_tol) {
        $self->log->trace("Test auf gedrehtes Bild");
        $scaling_factor_width = $image_height_mm / $pdf_width_mm;
        $scaling_factor_height = $image_width_mm / $pdf_height_mm;
        $deviation_width_height_percent =
            abs($scaling_factor_height - $scaling_factor_width)
            / $scaling_factor_width * 100;
        $self->log->trace( "Abweichung (gedreht) "
            . sprintf("%.1f Proc.",$deviation_width_height_percent)
        );
    }
    if ($self->has_resolution_correction) {
        $self->log->debug(
            'Fixed scaling factor: ' . $self->resolution_correction
        );
        return $self->resolution_correction;
    }
    if ($deviation_width_height_percent > $width_height_tol) {
        $self->log->logcroak(
            "Scaling factor height <> Scaling factor  width"
            . sprintf("%.3f", $image_height_mm / $pdf_height_mm)
            . ' <> '
            . sprintf("%.3f", $image_width_mm / $pdf_width_mm)
            .  sprintf(", %.1f Percent", $deviation_width_height_percent_save)
            . "\n eventually you should rise "
            . "--deviation_width_height_tolerance_percent" 
        )
    }    
    my $scaling_factor = $scaling_factor_height;
    my $deviation_percent
        = abs( $scaling_factor - 1 ) * 100;
    $self->log->trace(
        "Scaling factor: " . sprintf("%.3f", $scaling_factor)
        . " corr. of resolution " . sprintf("%.3f", 1)
        . " deviation: " . sprintf("%.1f", $deviation_percent) . "%"
        
    );
    if ($deviation_percent > $tol) {
        foreach my $fixed_factor (@$fixed_factors) {
            $deviation_percent = abs( $scaling_factor - $fixed_factor ) * 100;     
            if ($deviation_percent <= $tol) {
                $self->log->info(
                    "Resolution of PDF page will be corrected with fixed value:"
                    . sprintf("%.3f", $fixed_factor)
                );
                return $fixed_factor;
            }
        }
        $self->log->logcarp(
            "No fixed scaling value found!"
            . " Resolution of PDF page will be corrected with calculated value:"
            . sprintf("%.3f", $scaling_factor)
        );
        return $scaling_factor; 
    }
    else {
        return 1;    
    }
}

sub _build_source_pdf_page {
    my $self = shift;
    
    return $self->source_pdf->openpage($self->source_pdf_page_num);
}

sub _build_source_pdf_page_num { return (shift)->page_num }

sub import_source {
    my $self = shift;
    
    my $source_mediabox = [$self->source_pdf_page->get_mediabox];
    my $xoform =  $self->importPageIntoForm($self->source_pdf, $self->source_pdf_page_num);
    my $gfx = $self->page->gfx;
    $gfx->save;
    if ($self->do_rotate) {
        $gfx->transform(
            -translate => [$source_mediabox->[3],0],
            -rotate => 90,
        ); 
        $gfx->formimage($xoform,
                    ($self->with_logo_3
                    ? $self->footer_height->{$self->size_class} * 2
                    : $self->footer_height->{$self->size_class}),      
                    0,
                    $self->scaling_factor,
        );
    }
    else {
        $gfx->formimage($xoform,
                    0,
                    (
                        $self->with_logo_3
                        ? $self->footer_height->{$self->size_class} * 2
                        : $self->footer_height->{$self->size_class}
                    ),      
                    $self->scaling_factor,
        );
    }
    $gfx->restore;
}

# Bug #62287 for MooseX::UndefTolerant is not immutable-tolerant 
__PACKAGE__->meta->make_immutable;

1; # Magic true value required at end of module
__END__

=attr deviation_width_height_tolerance_percent

Maximum allowable deviation of the ratio of pdf page dimensions to image
dimensions in percent, that is
abs (pdf width / image width - pdf height / image height) /
(pdf width / image width * 100 )

=attr fixed_scaling_factors

A set of often used scaling factors, that are preferable chosen  

=attr resolution_correction

A factor to correct the resolution information of the image. That was neccessary
because of quirks of older versions of Abbyy FineReader. These FineReader
versions couldn't work correctly with arbitrary resolution values. Therefore the
resolution was set to e.g. 300 dpi and corrected afterwards by this factor.

=attr scaling_factor_tolerance_percent

Maximum deviation in percent of a scaling factor from a fixed value

=attr source_pdf

Source file in PDF format from that the single page is taken  

=attr source_pdf_page

Single PDF page taken from the PDF source file

=attr source_pdf_page_num

Page number of the processed page of the PDF source file

=attr logo_file_prefix_3

Right (fixed) part of logo filename of 3rd logo
