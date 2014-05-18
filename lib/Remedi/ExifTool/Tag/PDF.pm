use utf8;
package Remedi::ExifTool::Tag::PDF;

# ABSTRACT: Class for PDF metadata tags with ExifTool

use Moose;
use MooseX::AttributeShortcuts;
use Remedi::Types qw(ArrayRef PDFDate Str);
use namespace::autoclean;

extends 'Remedi::ExifTool::Tag::Base';

has 'Author' => (
    is => 'ro',
    isa => Str,
    #default => sub { '' },
    predicate => 1,
);

has 'CreateDate' => (
    is => 'ro',
    isa => PDFDate,
    coerce => 1,
    predicate => 1,
);

has 'Creator' => (
    is => 'ro',
    isa => Str,
    default => sub { '' },
    predicate => 1,
);

has 'Keywords' => (
    is => 'ro',
    isa => Str,
    #default => sub { [''] },
    predicate => 1,
);

has 'ModifyDate' => (
    is => 'ro',
    isa => PDFDate,
    coerce => 1,
    predicate => 1,
);

has 'Producer' => (
    is => 'ro',
    isa => Str,
    #default => sub { '' },
    predicate => 1,
);
   
has 'Subject' => (
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

