use utf8;
package Remedi::DigiFooter;

# ABSTRACT: Role for creating reference files with footer, thumbnails ...

use Moose::Role;

use DateTime::Duration;    
use List::Util qw(first);
use MooseX::AttributeShortcuts;
use MooseX::Types::LoadableClass qw(LoadableClass);
use Path::Tiny qw(path);
use Remedi::Singlepage::TIFF;
use Remedi::PDF::API2;
use Remedi::Types qw(ArrayRef ArrayRefOfSimpleStr Bool CodeRef Dir File FontSize
    Path HashRef HashRefOfNonEmptySimpleStr HashRefOfNum 
    ImagefileDestFormatKey ImagefileSourceFormat NonEmptySimpleStr Num
    PositiveNum Str Word Uri
);
use Try::Tiny;
use namespace::autoclean;
 
use Remedi::Units;

has 'dest_format_key' => (
    is => 'ro',
    isa => ImagefileDestFormatKey,
    required => 1
);

has 'deviation_width_height_tolerance_percent' => (
    is => 'ro', isa => PositiveNum, default => 12 );

has 'footer_background' => ( is => 'lazy', isa => HashRefOfNonEmptySimpleStr );

has 'footer_color' => ( is => 'lazy', isa => HashRefOfNonEmptySimpleStr );

has 'footer_height' => (  is => 'ro', isa => HashRefOfNum, default => sub { {
    small =>  7 * pt_pro_mm, large => 10 * pt_pro_mm
} } );

has 'footer_logo_file_infix' => ( is => 'ro', isa => HashRef[Word],
    default => sub { {
    color   => 'farbig', grayscale => 'grau', monochrome => 'sw'
} } );

has 'footer_logo_width' => ( is => 'ro', isa => HashRefOfNum,
    default => sub { { small => 25 * pt_pro_mm, large => 35 * pt_pro_mm } } );

has 'get_dest_format' => ( is => 'rw', isa => CodeRef, lazy => 1, builder => 1); 

has 'logo_file_prefix'    => ( is => 'ro', isa => Word );

has 'logo_file_prefix_2' =>  ( is => 'ro',   isa => Word, predicate => 1 );

has 'logo_file_prefix_3' => ( is => 'ro', isa => Word, predicate => 1 );

has 'logo_font_size'     => ( is => 'lazy', isa => FontSize );

has 'logo_font_type'     => ( is => 'lazy', isa => Word );

has 'logo_path'           => ( is => 'ro', isa => Dir, coerce => 1 );

has 'logo_path_2' => ( is => 'ro', isa => Path, predicate => 1, coerce => 1 );

has 'logo_path_3' => (is => 'ro', isa => Path, predicate => 1, coerce => 1);

has 'logo_text_2' => ( is => 'ro', isa => ArrayRefOfSimpleStr, predicate => 1 );

has 'logo_url'            => ( is => 'ro', isa => Uri, coerce => 1 );

has 'logo_url_2'  => ( is => 'ro', isa => Uri,  predicate => 1, coerce => 1 );

has 'logo_url_3'  => ( is => 'ro', isa => Uri, predicate => 1, coerce =>1 );

has '_name' => ( is => 'ro', isa => Str, default => 'DigiFooter' );

has 'pdf_class' => ( is => 'rw', isa => LoadableClass, coerce => 1 );

has 'pdf_release_threshold' => (is => 'ro', isa => PositiveNum, default => 300);

has 'resolution_correction' => ( is => 'ro', isa => Num, predicate => 1 );

has 'scaling_factor_tolerance_percent' => (
    is => 'ro', isa => PositiveNum, default => 3 );

has 'source_format' => (
    is => 'ro', isa => ImagefileSourceFormat, coerce => 1, required => 1);

# TODO Should be of type Path rather than Str
has 'source_pdf_name' => ( is => 'lazy', isa => Str );

has 'source_pdf_dir' => ( is => 'rw', isa => Dir, predicate => 1, coerce => 1 );

has 'source_pdf_files' => ( is => 'lazy', isa => ArrayRef[File] );  

has 'urn_font_size' => ( is => 'ro', isa => FontSize, default => 8 );

has 'urn_font_type' => ( is => 'ro', isa => Word, default => 'Helvetica' );

has 'urn_resolver_base' => ( is => 'ro', isa => Uri, coerce => 1,
    default => 'http://www.nbn-resolving.de/' );

sub _build_get_dest_format {
    my $self = shift,
    
    my %func_map = (
        'PDF'       => sub { 'PDF' },
        'JPEG_TIFF' => sub {
            my ($self, $image) = @_;
           
            $self->log->logcroak(
                'get_dest_format expects an archive imagefile, but '
                . ref($image) . ' found'
            ) unless ref $image eq 'Remedi::Imagefile::Archive';
            my $dest_format =  $image->format eq 'JPEG' ? 'PDF' : 'TIFF';
            $self->log->info(
                'destination format (get_dest_format): ' . $dest_format
            );
            return $dest_format;
        },
        'TIFF'     => sub { 'TIFF' },
    );
    return $func_map{$self->dest_format_key};
}

sub _build_footer_background {
    { color   => '#E0E0E0', grayscale => '#E0E0E0', monochrome => 'white' }
}

sub _build_footer_color {
    { color => 'black', grayscale => 'black', monochrome => 'black' }
}

sub _build_logo_font_size { (shift)->urn_font_size }

sub _build_logo_font_type { (shift)->urn_font_type }

sub _build_source_pdf_name {
    my $self = shift;
    
    $self->log->logcroak("Fatal error in _build_source_pdf_name()!")
        unless $self->source_format eq 'PDF';
    my $reg = $self->regex_filestem_prefix . '.pdf';
    my $image_dir = $self->working_dir;
    my @pdfs = grep { $_ =~ /$reg/ }  $image_dir->children;
    $self->log->logcroak("No PDF file found in '$image_dir' with regex '$reg'")
        unless @pdfs; 
    $self->log->logcroak("More then one PDF file found in '$image_dir'."
        . "\nChoose the PDF file with --source_pdf_name!")
            if @pdfs > 1;
    $self->log->debug("PDF source file: " . $pdfs[0]->relative);
    return $pdfs[0]->stringify;
}

sub _build_source_pdf_files {
    my $self = shift;
    
    my @list = sort grep {!/Thumbs\.db/i} $self->source_pdf_dir->children;
    $self->log->logcroak("No PDF files in ". $self->source_pdf_dir) unless @list;
    return \@list;
}

sub create_pdf_with_footer {
    my $self = shift;
    my $image = shift;
    my $page_num = shift;
    my $source_pdf = shift;
    my $source_pdf_page_num = shift;
    my $log = $self->log;

    $log->debug(
        $self->has_resolution_correction ? 'fixed resolution correction'
            : 'no fixed resolution correction'
    );    
    my $format = $self->source_format;
    $self->pdf_class('Remedi::Singlepage::PDF::From' . $format);
    my $init_args = {
        creator_pdf_info => $self->creator_pdf_info,
        creator => $self->creator,
        deviation_width_height_tolerance_percent =>
            $self->deviation_width_height_tolerance_percent,
        footer_background => $self->footer_background,
        footer_color => $self->footer_color,
        footer_height => $self->footer_height,
        footer_logo_file_infix => $self->footer_logo_file_infix,
        footer_logo_width => $self->footer_logo_width,
        image  => $image,
        log_level => $self->log_level,
        logo_file_prefix => $self->logo_file_prefix,
        logo_font_type => $self->logo_font_type,
        logo_font_size => $self->logo_font_size,
        logo_path => $self->logo_path,
        logo_url => $self->logo_url,
        page_num => $page_num,
        pages_total => $self->pages_total,
        scaling_factor_tolerance_percent =>
            $self->scaling_factor_tolerance_percent,
        title => $self->title,
        urn_font_size => $self->urn_font_size,
        urn_font_type => $self->urn_font_type,
        urn_level => $self->urn_level,
        urn_resolver_base => $self->urn_resolver_base,
    };
    foreach my $attrib ( qw(
        author
        logo_file_prefix_2
        logo_file_prefix_3
        logo_path_2
        logo_path_3        
        logo_text_2
        logo_url_2
        logo_url_3
        resolution_correction
    ) ) {
        $self->set_init_args($init_args, $attrib)
    }
    $init_args->{source_pdf} = $source_pdf if $format eq 'PDF';
    $init_args->{source_pdf_page_num} = $source_pdf_page_num
        if defined($source_pdf_page_num);
    my $pdf;
    try {
        $pdf = $self->pdf_class->new($init_args);
        $pdf->create_footer($self->_reference_dir);
    }
    catch {
        $pdf->pdf->release if $pdf && $pdf->can('pdf');
        
        # If there is not enough space on the bottom side, in case of PDF we try
        # to put the footer on the left side of the page, therefore the page
        # will be rotated by 90 degrees anti clockwise
        if ( $format eq 'PDF' && /No space for URN/ ) { 
            $log->warn("Image will be rotated");
            # flip the do_rotate param
            $init_args->{do_rotate} =  $init_args->{do_rotate} ? 0 : 1;
            $pdf = $self->pdf_class->new($init_args);
            $pdf->create_footer($self->_reference_dir);
        } else {
            $log->logdie("Creating footer died at page '$page_num': $_");
        } 
    }       
}


sub create_image_with_footer {
    my $self = shift;
    my $image = shift;

    my $init_args = {
        footer_background => $self->footer_background,
        footer_color => $self->footer_color,
        footer_height => $self->footer_height,
        footer_logo_file_infix => $self->footer_logo_file_infix,
        footer_logo_width => $self->footer_logo_width,
        image  => $image,
        logo_file_prefix => $self->logo_file_prefix,
        logo_font_size => $self->logo_font_size,
        logo_path => $self->logo_path,
        profile => $self->profile,
        tempdir => $self->tempdir,
                                # we pass it to have one tempdir for all files
        urn_font_size => $self->urn_font_size,
        urn_font_type => $self->urn_font_type,
        urn_level => $self->urn_level,
    };
    foreach my $attrib ( qw(
        logo_file_prefix_2
        logo_path_2
    ) ) {
        $self->set_init_args($init_args, $attrib)
    }    
    my $tiff = Remedi::Singlepage::TIFF->new($init_args);
    $tiff->create_footer($self->_reference_dir);   
}


sub make_footer {
    my $self = shift;

    my $page_num = 0;
    my $source_pdf;
    $self->log->debug("Format of source file(s): " . $self->source_format);
    if ($self->source_format eq 'PDF') {
        if ($self->has_source_pdf_dir) {
            # confess(join ' ', @{$self->source_pdf_files});
    
        } else {
            try {
                $source_pdf = Remedi::PDF::API2->open(
                    file =>$self->source_pdf_name
                );
            }
            catch {
                 $self->log->logcroak("Couldn't open PDF file '"
                    . $self->source_pdf_name .  "': $_");   
            
            };
            my $source_pdf_pages = $source_pdf->pages;
            $self->log->info("Pages of PDF source file: " . $source_pdf_pages);
            $self->log->logcroak(sprintf(
                "Pages of PDF source file (%s) <> count of archive files (%s)",
                $source_pdf_pages, $self->pages_total
            )) unless $source_pdf_pages == $self->pages_total;
        }
    }
    foreach my $imagefile (@{$self->archive_files}) {
        $page_num++;
        $self->log->info("-- Page $page_num --");
        $self->log->info('... file: ' . $imagefile->basename);
        $imagefile->dest_format( $self->get_dest_format->($self, $imagefile) )
            # if $self->can('get_dest_format')
        ;
        $self->log->trace('... dest format: ' . $imagefile->dest_format); 
        if ($self->has_source_pdf_dir) {
            my $source_pdf_name = shift @{$self->source_pdf_files};
            $source_pdf->release() if $source_pdf;
            $source_pdf = Remedi::PDF::API2->open(file => $source_pdf_name);
        } else {
            if ( ($self->source_format eq 'PDF')
                  && ($page_num % $self->pdf_release_threshold == 0)) {
                $self->log->trace( $self->source_pdf_name . ' will be closed '
                    . ' and opened again because of memory leaks in PDF::API2'); 
                $source_pdf->release();
                $source_pdf = Remedi::PDF::API2->open(file =>$self->source_pdf_name);
            }
        }
        if ( $imagefile->dest_format eq 'PDF' ) {
            if ($self->has_source_pdf_dir) {
                $self->create_pdf_with_footer($imagefile, $page_num, $source_pdf, 1);
            } else {
                $self->create_pdf_with_footer($imagefile, $page_num, $source_pdf);
            }
        }
        else { 
            $self->create_image_with_footer($imagefile);
        }
        $imagefile->create_thumbnail($self->_thumbnail_dir);
    }
    $self->finish;
}
no Remedi::Units;
1; # Magic true value required at end of module

__END__

=attr dest_format_key

=attr deviation_width_height_tolerance_percent

Maximum allowable deviation of the ratio of pdf page dimensions to image
dimensions in percent, that is
abs (pdf width / image width - pdf height / image height) /
(pdf width / image width * 100 )

=attr footer_background

Background color of footer depending on the color type (color, greyscale or
monochrome) of the image.
Color could be a RGB value, e.g. #E0E0E0, or a color name known to ImageMagick

=attr footer_color

Color of text, lines ... depending on the color type (color, greyscale or
monochrome) of the image.
Color could be a RGB value, e.g. #E0E0E0, or a color name known to ImageMagick

=attr footer_height

Height of footer in pixel depending on size class of the image

=attr footer_logo_file_infix

Middle part of logo filename depending on color type of the image

=attr footer_logo_width

Selecting different logo files according to the size_class of the image 

=attr logo_file_prefix

Right (fixed) part of logo filename

=attr logo_file_prefix_2

Right (fixed) part of logo filename of 2nd logo

=attr logo_file_prefix_3

Right (fixed) part of logo filename of 3rd logo

=attr logo_font_size

Font size of describing text for the 2nd involved library as an alternative to
a logo 

=attr logo_font_type

Font type of describing text for the 2nd involved library as an alternative to
a logo 

=attr logo_path

Path to the directory of logo files

=attr logo_path_2

Path to the directory of logo files to the 2nd logo

=attr logo_path_3

Path to the directory of logo files to the 3rd logo

=attr logo_text_2

Alternatively instead of a logo a describing text for the 2nd involved library,
normally the library to which the original belongs 

=attr logo_url

Link to the Institution

=attr logo_url_2

Link to the Institution to which the 2nd logo belongs

=attr logo_url_3

Link to the Institution to which the 3rd logo belongs

=attr pdf_class

Depending on the format of the source file a subclass of
C<Remedi::Singlepage::PDF> will be loaded.

=attr pdf_release_threshold

Limit of PDF pages which will be processed in one step.
PDF objects instantiated by PDF::API2 leaking because of their internal
structure

=attr resolution_correction

A factor to correct the resolution information of the image. That was neccessary
because of quirks of older versions of Abbyy FineReader. These FineReader
versions couldn't work correctly with arbitrary resolution values. Therefore the
resolution was set to e.g. 300 dpi and corrected afterwards by this factor.

=attr scaling_factor_tolerance_percent

Maximum deviation in percent of a scaling factor from a fixed value

=attr source_format

Image format of the source file

=attr source_pdf_name

File name of the source file in PDF format

=attr source_pdf_dir

If this parameter is set single-page PDF files are used as source files instead
of a multi-page PDF.

=attr source_pdf_files

List of single-page PDFs

=attr urn_font_size

Font size of URN text on footer line

=attr urn_font_type

Font type of URN text on footer line

=attr urn_resolver_base

Base URL for resolving URNs, e.g. http://www.nbn-resolving.de/
