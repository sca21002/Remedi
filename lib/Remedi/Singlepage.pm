use utf8;
package Remedi::Singlepage;

# ABSTRACT: Base class for a image file with footer

use Moose;
use MooseX::AttributeShortcuts;
use Log::Log4perl::Level;
use Remedi::Units;
use Remedi::Types qw(Bool Dir File FontSize HashRefOfNonEmptySimpleStr
    HashRefOfNum HashRefOfWord Imagefile LogLevel Path Word URN_level);
use namespace::autoclean;

has 'footer_background'       => (
    is => 'ro',
    isa => HashRefOfNonEmptySimpleStr,
    required => 1
);

has 'footer_color' => (
    is => 'ro',
    isa => HashRefOfNonEmptySimpleStr,
    required => 1,
);

has 'footer_height' => (
    is => 'ro',
    isa => HashRefOfNum,
    required => 1
);

has 'footer_logo_file_infix' => (
    is => 'ro',
    isa => HashRefOfWord,
    required => 1
);

has 'footer_logo_file_infix' => (
    is => 'ro',
    isa => HashRefOfWord,
    required => 1
);
has 'footer_logo_width'      => (
    is => 'ro',
    isa => HashRefOfNum,
    required => 1
);

has 'image' => ( is => 'ro', isa => Imagefile, required => 1 );

has 'log_level' => ( is => 'lazy', isa => LogLevel, coerce => 1 );

has 'logo_file'          => ( isa => File, is => 'lazy', coerce => 1 );

has 'logo_file_2'        => ( isa => File, is => 'lazy', coerce => 1 );

has 'logo_file_prefix'   => ( is => 'ro', isa => Word, required => 1 );

has 'logo_file_prefix_2' => ( is => 'ro', isa => Word, predicate => 1 );

has 'logo_path'      => ( is => 'ro', isa => Dir, coerce => 1, required => 1 );

has 'logo_path_2'    => ( is => 'ro', isa => Dir, predicate => 1, coerce => 1 );

has 'urn_font_size'     => ( is => 'ro', isa => FontSize, required => 1 );

has 'urn_font_type'     => ( is => 'ro', isa => Word, required => 1 );

has 'urn_level' => ( is => 'ro', isa => URN_level, default => 'single_page' );

sub BUILD {
    my $self = shift;

    $self->log->level($self->log_level);
}

sub _build_log_level { $INFO } 

__PACKAGE__->meta->make_immutable;

1; # Magic true value required at end of module
__END__

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

=attr image

Scan file
Used to get informations like original size, color type, filename

=attr logo_file

Logo file

=attr logo_file_2

Logo file of 2nd logo

=attr logo_file_prefix

Right (fixed) part of logo filename

=attr logo_file_prefix_2

Right (fixed) part of logo filename of 2nd logo

=attr logo_path

Path to the directory of logo files

=attr logo_path_2

Path to the directory of logo files of 2nd logo

=attr urn_font_size

Font size of URN text on footer line

=attr urn_font_type

Font type of URN text on footer line

=attr urn_level (default: single_page)

Defines to what extent URNs should be applied to the digital entities.
Possible values are no_urn, object, and single_page
