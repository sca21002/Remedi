use utf8;
package Remedi::ExifTool::Tag::XMP::DC;

# ABSTRACT: Class for metadata tags with ExifTool in XMP::DC namespace

use Moose;
use MooseX::AttributeShortcuts;
use Remedi::Types qw(Str);
use namespace::autoclean;

extends 'Remedi::ExifTool::Tag::Base';

has 'Date' => (
    is => 'ro',
    isa => Str,
    #default => sub { '' },
    predicate => 1,
);

has 'Creator' => (
    is => 'ro',
    isa => Str,
    #default => sub { '' },
    predicate => 1,
);

has 'Identifier' => (
    is => 'ro',
    isa => Str,
    #default => sub { '' },
    predicate => 1,
);

has 'Publisher' => (
    is => 'ro',
    isa => Str,
    #default => sub { '' },
    predicate => 1,
);

has 'Source' => (
    is => 'ro',
    isa => Str,
    #default => sub { '' },
    predicate => 1,
);

has 'Title' => (
    is => 'ro',
    isa => Str,
    #default => sub { '' },
    predicate => 1,
);

__PACKAGE__->meta->make_immutable;

1; # Magic true value required at end of module

