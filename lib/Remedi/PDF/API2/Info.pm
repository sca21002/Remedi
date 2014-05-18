use utf8;
package Remedi::PDF::API2::Info;

# ABSTRACT: Class for Info (meta data) info PDF::API2 

use Moose;
use MooseX::AttributeShortcuts;
use PDF::API2;
use Remedi::Types qw(HashRef PDFDate Str);
use namespace::autoclean;

has 'Author' => (
    is => 'ro',
    isa => Str,
    default => sub {''},
);

has 'CreationDate' => (
    is => 'lazy',
    isa => PDFDate,
    coerce => 1,
);

has 'Creator' => (
    is => 'ro',
    isa => Str,
    default => sub { '' },                  
);

has 'Producer' => (
    is => 'ro',
    isa => Str,
    default => sub { 'PDF::API2' },
);

has 'Title' => (
    is => 'ro',
    isa => Str,
    default => sub { '' },
);

has 'Keywords' => (
    is => 'ro',
    isa => Str,
    default => sub { '' },
);

has 'info_href' => (
    is => 'lazy',
    isa => HashRef,
);

sub _build_CreationDate {
    DateTime->now(
        locale => 'de_DE',
        time_zone => 'Europe/Berlin',
    );
}

sub _build_info_href {
    my $self = shift;
    
    my $info_href;
    foreach my $attr (qw(Author CreationDate Creator Producer Title Keywords)) {
        $info_href->{$attr} = $self->$attr if $self->$attr;        
    } 
    return $info_href
}

__PACKAGE__->meta->make_immutable;

1;