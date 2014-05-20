use utf8;
package Remedi::Singlepage::PDF;

# ABSTRACT: PDF file with footer line

use Moose;
    extends qw(Remedi::Singlepage);
    with    qw(MooseX::Log::Log4perl);
use Remedi::PDF::API2;
use DateTime;
use List::Util qw{max};
use Remedi::Units;
use Remedi::Types qw(
    ArrayRef ArrayRefOfSimpleStr Bool Colortype Dir File FontSize
    NonEmptySimpleStr Int NonEmptyDoubleStr Num
    RemediPdfApi2 RemediPdfApi2Page Word Uri
);
use Path::Tiny;
use namespace::autoclean;

has 'author'        => ( is => 'ro', isa => NonEmptySimpleStr, predicate => 1 );
has 'colortype'               => ( is => 'lazy', isa => Colortype );
has 'creator_pdf_info' => (is => 'ro', isa => NonEmptySimpleStr, required => 1);
has 'cropbox'                 => ( is => 'lazy' ,isa => ArrayRef[Num]);

has 'do_rotate'         => ( is => 'rw', isa => Bool, default => 0 );

has 'logo_file_prefix_3' => ( is => 'ro', isa => Word, predicate => 1 );

has 'logo_file_3'      => ( isa => File, is => 'lazy', coerce => 1 );

has 'logo_font_size'   => ( is => 'ro', isa => FontSize );

has 'logo_font_type'   => ( is => 'ro', isa => Word );

has 'logo_path_3' => (is => 'ro', isa => Dir, predicate => 1, coerce => 1);

has 'logo_text_2' => ( is => 'ro', isa => ArrayRefOfSimpleStr, predicate => 1 );

has 'logo_url'        => ( is => 'ro', isa => Uri, coerce => 1, required => 1 );

has 'logo_url_2' => ( is => 'ro', isa => Uri, predicate => 1, coerce => 1 );

has 'logo_url_3'  => ( is => 'ro', isa => Uri, predicate => 1, coerce =>1 );

has 'page_num'                => ( is => 'ro', isa => Int, required => 1 );

has 'pages_total'             => ( is => 'ro', isa => Int, required => 1 );

has '+image'          => ( 
    handles => [ qw( size_class urn filestem ) ]
);

has 'mediabox'                => ( isa => ArrayRef[Num], is => 'lazy');

has 'page' => ( is => 'lazy', isa => RemediPdfApi2Page );

has 'pdf' => ( is => 'lazy', isa     => RemediPdfApi2,
    handles => [ qw( image_jpeg image_tiff importPageIntoForm corefont info ) ],
); 

has 'scaling_factor'     => ( is => 'lazy', isa => Num );

has 'title'          => ( is => 'ro', isa => NonEmptyDoubleStr, required => 1 );

has 'urn_resolver_base' => (is => 'ro', isa => Uri, coerce => 1, required => 1);

has 'with_logo_3'   => ( is => 'lazy', isa => Bool );


sub _build_logo_file_2 {
    my $self = shift;
   
    return unless $self->has_logo_file_prefix_2 and $self->has_logo_path_2;
    my $size_class = $self->size_class;
    my $logo_filename_2
        = $self->logo_file_prefix_2
          . $self->footer_logo_file_infix->{$self->colortype} . '_'
          . sprintf("%.0f",
                $self->footer_logo_width->{$size_class} / pt_pro_mm)
            . '_'
            . sprintf("%.0f",
                $self->footer_height->{$size_class} / pt_pro_mm)
            . '.pdf'
            ;
    return path( $self->logo_path_2, $logo_filename_2 ); 
}



sub _build_logo_file {
    my $self = shift;
   
    my $size_class = $self->size_class;
    my $logo_filename
        = $self->logo_file_prefix
          . $self->footer_logo_file_infix->{$self->colortype} . '_'
          . sprintf("%.0f",
                $self->footer_logo_width->{$size_class} / pt_pro_mm)
            . '_'
            . sprintf("%.0f",
                $self->footer_height->{$size_class} / pt_pro_mm)
            . '.pdf'
            ;

    return path( $self->logo_path, $logo_filename ); 
}

sub _build_page {
    my $self = shift;
    
    my $page = $self->pdf->page(0);
    $page->mediabox(@{$self->mediabox});
    $page->cropbox(@{$self->cropbox});
    return $page;
}

sub _build_pdf { Remedi::PDF::API2->new() }

sub _build_logo_file_3 {
    my $self = shift;
   
    my $size_class = $self->size_class;
    my $logo_filename_3
        = $self->logo_file_prefix_3
          . $self->footer_logo_file_infix->{$self->colortype} . '_'
          . sprintf("%.0f",
                $self->footer_logo_width->{$size_class} / pt_pro_mm)
            . '_'
            . sprintf("%.0f",
                $self->footer_height->{$size_class} / pt_pro_mm)
            . '.pdf'
            ;
    return path( $self->logo_path_3, $logo_filename_3 ); 
}

sub _build_with_logo_3 { shift->has_logo_file_prefix_3 }


sub add_logo {
    my $self = shift;
    
    my $logo_pdf = Remedi::PDF::API2->open(file => $self->logo_file->stringify)
        or $self->log->logcroak("Couldn't open $self->logo_file: $!"); 
    my $cropbox = $self->cropbox;
    my $mediabox = $self->mediabox;
    my $size_class = $self->size_class;
    my $footer_height = $self->footer_height->{$size_class};
    $footer_height += $footer_height if $self->with_logo_3;
    
    my $xoform =  $self->importPageIntoForm($logo_pdf);
    # background for newly added bottom
    my $gfx = $self->page->gfx;
    $gfx->save;
    $gfx->fillcolor( $self->footer_background->{$self->colortype} );
    $gfx->rect(
        $self->mediabox->[0],
        $self->mediabox->[1],
        $self->mediabox->[2] - $self->mediabox->[0],
        $footer_height + $cropbox->[1] - $self->mediabox->[1],
    );
    $gfx->fill;
    $gfx->restore;

    # place logo on the lower left edge 
    $gfx->formimage( $xoform, $cropbox->[0], $cropbox->[1], 1 );

    my $annot = $self->page->annotation;
    my $url = $self->logo_url;
    my $rect_ref;
    if ($self->with_logo_3) {
        $rect_ref = [
            $self->cropbox->[0],
            $self->cropbox->[1],
            $self->footer_logo_width->{$size_class} + $cropbox->[0],
            $footer_height / 2 + $cropbox->[1],
        ];
    } else {    
        $rect_ref = [
            $self->cropbox->[0],
            $self->cropbox->[1],
            $self->footer_logo_width->{$size_class} + $cropbox->[0],
            $footer_height + $cropbox->[1],
        ];
    }
    $annot->url ($url, -rect => $rect_ref );
    $logo_pdf->release();
}

sub add_logo_2 {
    my $self = shift;
    
    $self->log->logcroak('Either additional text (logo_text_2) '
        . 'or additional logo in PDF format (logo_file_prefix_2)')
        if $self->has_logo_text_2 && $self->has_logo_file_prefix_2;
    return $self->add_logo_text_2() if $self->has_logo_text_2;
    return $self->add_logo_pdf_2()  if $self->has_logo_file_prefix_2;
    return;
}

sub add_logo_pdf_2 {
    my $self = shift;
    
    my $logo_pdf = Remedi::PDF::API2->open(
        file => $self->logo_file_2->stringify
    ) or $self->log->logcroak( "Couldn't open '". $self->logo_file_2. "': $!" );
    my $logo_pdf_page = $logo_pdf->openpage(1);
    my $logo_pdf_mediabox = [ $logo_pdf_page->get_mediabox ];
    my $cropbox = $self->cropbox;
    my $size_class = $self->size_class;
    my $footer_height = $self->footer_height->{$size_class};
    
    my $xoform =  $self->importPageIntoForm($logo_pdf);
    my $gfx = $self->page->gfx;
    # place logo on the lower right edge 
    $gfx->formimage(
        $xoform,
        $cropbox->[2] - $logo_pdf_mediabox->[2],
        $cropbox->[1],
        1
    );
    if ( $self->has_logo_url_2 ) {
        my $ant = $self->page->annotation;
        my $rect_ref =    [ $cropbox->[2] - $logo_pdf_mediabox->[2],
                            $cropbox->[1],
                            $cropbox->[2],
                            $footer_height + $cropbox->[1],
                          ];
        $ant->url( $self->logo_url_2, -rect => $rect_ref );
    }
    $logo_pdf->release();
    return $logo_pdf_mediabox->[2];
}

sub add_logo_text_2 {
    my $self = shift;

    my $pdf = $self->pdf;
    my $page = $self->page;
    my $footer_height = $self->footer_height->{$self->size_class};
    my $cropbox = $self->cropbox;
    my $font_type = $self->logo_font_type;
    my $font = $pdf->corefont($font_type);
    my $font_size = $self->logo_font_size;
    
    my $txt = $page->text;   # new text content object
    $txt->textstart;
    
    $txt->font($font, $font_size);
    
    my $line_spacing = $font_size * 0.43;
    my $txt_height   = $font_size * 0.7;
    my $content = $self->logo_text_2;
    my $txtblock_width = max map { $txt->advancewidth($_) } @$content;
    my $line_count = scalar @$content;
    
    my $bottom_margin
        = ( $footer_height 
            - $line_count * $txt_height
            - ($line_count-1) * $line_spacing
          )
          / 2
          + $cropbox->[1]
          ;
    $self->log->logcroak("Space needed for text '" . @$content
                      . "' exceeds height of the footer")
        # if $bottom_margin < 0;
        if $bottom_margin < $cropbox->[1];
    foreach my $index (0 .. $line_count-1) {
        my $line_spacing_sum = $line_spacing * ($line_count - $index-1);
        $txt->translate(
            $cropbox->[2] - $footer_height / 4 - $txtblock_width ,
            $bottom_margin +  ($line_count - $index -1) * $txt_height
                + $line_spacing_sum
        );
        $txt->text($content->[$index]);
    }
    $txt->textend;
    
    if ( $self->has_logo_url_2 ) {
        my $ant = $page->annotation;
        my $rect_ref =    [ $cropbox->[2]
                            - $txtblock_width
                            - $footer_height / 4 ,
                            $cropbox->[1],
                            $cropbox->[2],
                            $footer_height + $cropbox->[1],
                          ];
        $ant->url( $self->logo_url_2, -rect => $rect_ref );
    }
   
    return $txtblock_width + $footer_height / 4;    
}

sub add_logo_3 {
    my $self = shift;
    
    return $self->add_logo_pdf_3() if $self->has_logo_file_prefix_3;
    return;
}

sub add_logo_pdf_3 {
    my $self = shift;
    
    my $logo_pdf = Remedi::PDF::API2->open(
        file => $self->logo_file_3->stringify
    ) or $self->log->logcroak(
        "Couldn't open '" . $self->logo_file_3 . "': $!"
    );
    my $logo_pdf_page = $logo_pdf->openpage(1);
    my $logo_pdf_cropbox = [ $logo_pdf_page->get_cropbox ];
    my $cropbox = $self->cropbox;
    my $size_class = $self->size_class;
    my $footer_height = $self->footer_height->{$size_class};
    
    my $xoform =  $self->importPageIntoForm($logo_pdf);
    my $gfx = $self->page->gfx;
    # place third logo in the middle of the lower side
    $gfx->formimage(
        $xoform,
        (   $cropbox->[2] + $cropbox->[0]
            - $logo_pdf_cropbox->[2] - $logo_pdf_cropbox->[0]
        ) / 2,
        $cropbox->[1],
        1
    );
    if (my $url = $self->logo_url_3 ) {
        my $ant = $self->page->annotation;
        my $rect_ref = [ (    $cropbox->[2] + $cropbox->[0]
                              - $logo_pdf_cropbox->[2]
                              + $logo_pdf_cropbox->[0]
                          ) / 2,
                          $cropbox->[1],
                          (   $cropbox->[2] + $cropbox->[0]
                              + $logo_pdf_cropbox->[2]
                              - $logo_pdf_cropbox->[0]
                          )/2,
                          $footer_height + $cropbox->[1],
                       ];
        $ant->url ($url, -rect => $rect_ref );
    }
    $logo_pdf->release();
    return $logo_pdf_cropbox->[2] - $logo_pdf_cropbox->[0];
}

sub create_footer {
    my $self = shift;
    my $dest_dir = shift;
 
    $self->import_source();
    $self->add_logo();
    my $logo_width_2 = $self->add_logo_2();
    my $has_logo_3 = $self->add_logo_3();
    $self->write_urn($logo_width_2) if $self->urn_level eq 'single_page';
    $self->draw_footer_line();  
    $self->write_pdf_info();
    $self->save( path($dest_dir, $self->image->filestem . '.pdf')->stringify );
    $self->pdf->release();    
}

sub draw_footer_line {
    my $self = shift;
    
    # a small line to divide footer from scan image 
    my $gfx = $self->page->gfx;
    $gfx->linewidth(0.1);
    my $color = $self->footer_color->{$self->colortype};
    $gfx->strokecolor($color);
    my $footer_height = $self->footer_height->{$self->size_class};
    $footer_height += $footer_height if $self->with_logo_3;
    $gfx->move($self->cropbox->[0], $footer_height + $self->cropbox->[1]);
    $gfx->line(
        $self->mediabox->[2], 
        $footer_height + $self->cropbox->[1]
    );
    $gfx->stroke;    
}

sub save {
    my $self = shift;
    my $pdf_name = shift;
    
    $self->log->logcroak(
        "Save failed, no path given for" . $self->filestem
    ) unless $pdf_name;
    if ($self->do_rotate) {
        $self->page->rotate(90);    
    }
    $self->pdf->saveas($pdf_name);
}

sub write_pdf_info {
    my $self = shift;
    
    my $pages_total = $self->pages_total;
    my $page_num = $self->page_num;
    # creation date in acrobat date format, e.g. D:20080428120000+02'00'  
    my $creation_date_obj = DateTime->now( locale => 'de_DE' );
    $creation_date_obj->set_time_zone('Europe/Berlin');
    my $creation_date = $creation_date_obj->strftime('D:%Y%m%d%H%M%S%z');
    $creation_date =~ s/([+-])(\d{2})(\d{2})\z/$1$2'$3'/
        or $self->log->logcroak("Falsche Zeitangaben $creation_date");
    # add meta data
    my $title = $self->title . ". - " . $page_num . '/' . $pages_total;
    my %info = (
        'CreationDate' => $creation_date,
        'Creator'      => $self->creator_pdf_info,
        'Producer'     => 'PDF::API2',
        'Title'        => $title,
    );
    $info{'Author'}   = $self->author if $self->has_author;
    $info{'Keywords'} = $self->urn if $self->urn_level eq 'single_page';  
    $self->info(%info);
}

sub write_urn {
    my $self = shift;
    my $logo_width_2 = shift || 0;
   
    # set the font
    my $font_type = $self->urn_font_type;
    my $font = $self->corefont($font_type);
    my $font_size = $self->urn_font_size;
    my $cropbox = $self->cropbox;
    my $size_class = $self->size_class;
    my $footer_height = $self->footer_height->{$size_class};

    $self->log->trace(
        $self->_print_pdf_page_box( $cropbox, 'Cropbox' )
    );  

    # put urn in the footer
    
    my $txt = $self->page->text;   # new text content object
    my $color = $self->footer_color->{$self->colortype};
    $txt->strokecolor($color);
    $txt->fillcolor($color);
    $txt->textstart;
    $txt->font($font, $font_size);
 
    my $urn = $self->urn;
    my $free_space;
    if ($self->with_logo_3) {
        $free_space = $cropbox->[2] - $cropbox->[0];    
    } else {
        $free_space = $cropbox->[2]
                     - $self->footer_logo_width->{$size_class}
                     - $logo_width_2
                     - $cropbox->[0]
                     ;
    }
    my $urn_width = $txt->advancewidth($urn);    
    my $free_space_with_urn = $free_space - $urn_width;
    
    $self->log->trace($self->_print_pt($free_space, 'Freiraum fuer URN'));
    $self->log->trace($self->_print_pt($footer_height, 'Fusshoehe'));  
    $self->log->trace($self->_print_pt($urn_width, 'Breite der URN'));  

    while ( $free_space_with_urn < $footer_height ) {
        $font_size--;
        $self->log->warn("Reduziere Fontgroesse der URN auf $font_size");
        $self->log->logcroak("No space for URN") if $font_size < 3;
        $txt->font($font, $font_size);
        $urn_width = $txt->advancewidth($urn);
        $self->log->trace($self->_print_pt($urn_width, 'Breite der URN'));  
        $free_space_with_urn = $free_space - $urn_width;
    }
   
    my $urn_pos_x; 
    if ($self->with_logo_3) {
        $urn_pos_x = $cropbox->[0]
                     + $free_space_with_urn / 2
                    ;
    } else {

        $urn_pos_x = $cropbox->[0]
                    + $self->footer_logo_width->{$size_class}
                    + $free_space_with_urn / 2
                    ;
    }
    my $urn_pos_y;
    if ($self->with_logo_3) {
        $urn_pos_y = ($footer_height - $font_size * 0.7) / 2
                    + $cropbox->[1]
                    + $footer_height
                    ;    
    } else {
        $urn_pos_y = ($footer_height - $font_size * 0.7) / 2
                    + $cropbox->[1]
                    ;
    }
    $txt->translate($urn_pos_x, $urn_pos_y);
    $txt->text($urn);
    $txt->textend;
    
    # a link
    my $annot = $self->page->annotation;
    my $url =  $self->urn_resolver_base . $urn;

    my $rect_ref; 
    
    if ($self->with_logo_3) {
        $rect_ref
            = [ $urn_pos_x,
                $footer_height + $cropbox->[1],
                $urn_pos_x + $urn_width,
                $footer_height * 2 + $cropbox->[1],
              ];
    } else {
        $rect_ref
            = [ $urn_pos_x,
                0,
                $urn_pos_x + $urn_width,
                $footer_height + $cropbox->[1],
              ];
    }
    $annot->url ($url, -rect => $rect_ref );    
}

sub _print_pt { ($_[2]||'') . ': ' . sprintf "%.1f", $_[1] * 25.4/72 }

sub _print_pdf_page_box {
    my ($self, $box, $message) = @_;
    
    return "Keine PDF-Seiten Box" unless $box;
    return ($message||'') . ': '
           . join ',', map {sprintf("%.1f", $_ * 25.4/72)} @$box;
}

# Bug #62287 for MooseX::UndefTolerant is not immutable-tolerant 
__PACKAGE__->meta->make_immutable;

1; # Magic true value required at end of module
__END__

=attr author

Author of the original work.
Used in the metadata of the PDF file

=attr colortype

values are monochrome, greyscale or color 

=attr creator_pdf_info

Clause describing the digital object as created from digitising by the creator
Used in the metadata of the PDF file

=attr cropbox

The CropBox of the PDF page defines the region to which the page contents are to
be clipped

=attr image

Scan file
Used to get informations like original size, color type, filename

=attr do_rotate

If true the image of the PDF page will be rotated (90 degree)

=attr logo_file_3

Logo file of 3rd logo

=attr logo_file_prefix_3

Right (fixed) part of logo filename of 3rd logo

=attr logo_font_size

Font size of describing text for the 2nd involved library as an alternative to
a logo 

=attr logo_font_type

Font type of describing text for the 2nd involved library as an alternative to
a logo 

=attr logo_path_3

Path to the directory of logo files of 3rd logo

=attr logo_text_2

Alternatively instead of a logo a describing text for the 2nd involved library,
normally the library to which the original belongs 

=attr logo_url

Link to the Institution

=attr logo_url_2

Link to the Institution to which the 2nd logo belongs

=attr logo_url_3

Link to the Institution to which the 3rd logo belongsLink to the Institution to
which the 3rd logo belongs

=attr page_num

Page number of the processed page

=attr pages_total

Count of pages

=attr mediabox

The mediaBox of a PDF page specifies the width and height of the page. It is the
largest box of a page.

=attr page

=attr pdf

The PDF from which the actual page is taken 

=attr scaling_factor

Factor to correct a fake resolution value intentionaly set before OCR-ing
because of quirks of older versions of Abbyy FineReader

=attr title

Title of the digitised work
Used in the metadata of the PDF files

=attr urn_resolver_base

Base URL for resolving URNs, e.g. http://www.nbn-resolving.de/

=attr with_logo_3

True if a 3rd logo should be added to footer

