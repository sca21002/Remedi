use utf8;
package Remedi::PDF::ExifTool::Info;

# ABSTRACT: Class for info (meta data) in a pdf file using ExifTool  

use Moose;
    with qw(
        Remedi::ExifTool::Writer
        MooseX::Log::Log4perl
    );
use MooseX::AttributeShortcuts;
use Remedi::Types qw(ArrayRef File PDFDate Str);
use namespace::autoclean;


has 'author' => (
    is => 'ro',
    isa => Str,
    predicate => 1,
);

has 'bv_nr' => (
    is => 'ro',
    isa => Str,
    predicate => 1,
);  

has 'create_date' => (
    is => 'ro',
    isa => PDFDate,
    coerce => 1,
    predicate => 1,
);

has 'creator' => (
    is => 'ro',
    isa => Str,
    predicate => 1,
);

has 'keywords' => (
    is => 'ro',
    isa => Str,
    predicate => 1,
);

has 'metadata_date' => (
    is => 'ro',
    isa => PDFDate,
    coerce => 1,
    predicate => 1,
);


has 'modify_date' => (
    is => 'ro',
    isa => PDFDate,
    coerce => 1,
    predicate => 1,
);

has 'producer' => (
    is => 'ro',
    isa => Str,
    predicate => 1,
);

has 'publisher' => (
    is => 'ro',
    isa => Str,
    predicate => 1,
);

has 'shelf_number' => (
    is => 'ro',
    isa => Str,
    predicate => 1,
);   
   
has 'subject' => (
    is => 'ro',
    isa => Str,
    predicate => 1,
);

has 'title' => (
    is => 'ro',
    isa => Str,
    predicate => 1,
);

has 'year_of_publication' => (
    is => 'ro',
    isa => Str,
    predicate => 1,
);

sub _build_tag_map {
    my $tag_map = {
        author              => [qw(PDF:Author XMP-dc:Creator)],   
        creator             => ['PDF:Creator'],
        keywords            => ['XMP-pdf:Keywords'],
        modify_date         => ['PDF:ModifyDate'],
        metadata_date       => ['XMP-xmp:MetadataDate'],
        publisher           => ['XMP-dc:Publisher'],
        shelf_number        => ['XMP-dc:Source'],
        title               => ['XMP-dc:Title'],
        bv_nr               => ['XMP-dc:Identifier'],
        year_of_publication => ['XMP-dc:Date'],
    };
    return $tag_map;
}

sub write_info {
    my $self = shift;
    
    $self->write($self->tag);
}

__PACKAGE__->meta->make_immutable; 
1;