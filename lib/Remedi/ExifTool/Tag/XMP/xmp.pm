use utf8;
package Remedi::ExifTool::Tag::XMP::XMP;

# ABSTRACT: Class for metadata tags with ExifTool in XMP::xmp namespace

use Moose;
use MooseX::AttributeShortcuts;
use Remedi::Types qw(PDFDate);
use namespace::autoclean;

extends 'Remedi::ExifTool::Tag::Base';

has 'CreateDate' => (
    is => 'ro',
    isa => PDFDate,
    coerce => 1,
    predicate => 1,
);

has 'MetadataDate' => (
    is => 'ro',
    isa => PDFDate,
    coerce => 1,
    predicate => 1,
);

has 'ModifyDate' => (
    is => 'ro',
    isa => PDFDate,
    coerce => 1,
    predicate => 1,
);



__PACKAGE__->meta->make_immutable;

1; # Magic true value required at end of module

