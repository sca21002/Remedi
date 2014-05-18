use utf8;
package Remedi::ExifTool::Tag::XMP::PDF;

# ABSTRACT: Class for metadata tags with ExifTool in XMP::xmp namespace

use Moose;
use MooseX::AttributeShortcuts;
use Remedi::Types qw(Str);
use namespace::autoclean;

extends 'Remedi::ExifTool::Tag::Base';

has 'Keywords' => (
    is => 'ro',
    isa => Str,
    predicate => 1,
);

__PACKAGE__->meta->make_immutable;

1; # Magic true value required at end of module

