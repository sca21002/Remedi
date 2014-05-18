package Remedi::PDF::CAM::Page;

# ABSTRACT: Class for a page in CAM::PDF 

use Moose;
use CAM::PDF;
use Remedi::PDF::CAM::Page::Image;
use MooseX::AttributeShortcuts;
use Remedi::Types qw(ArrayRef Int Str);
use namespace::autoclean;

has 'pageno' => (
    is => 'ro',
    isa => Int,
    required => 1,
);

has 'pdf' => (
    is => 'ro',
    isa => 'Remedi::PDF',
    required => 1,
);

has 'pagecontent' => ( is => 'lazy', isa => Str );
has 'parts'       => ( is => 'lazy', isa => ArrayRef[Str] );
has 'images'      => (
    is => 'lazy',
    isa => 'ArrayRef[Remedi::PDF::CAM::Page::Image]',
);

has 'text'        => ( is => 'lazy', isa => Str );

sub _build_pagecontent {
    my $self = shift;
    
    return $self->pdf->getPageContent($self->pageno);   
}

sub _build_parts {
    my $self = shift;
    
    my @parts = split /(\/[\w]+\s*Do)\b/xms, $self->pagecontent;
    return \@parts;
}

sub _build_images {
    my $self = shift;
    
    my @images;
    foreach my $part (@{$self->parts}) {
        if ($part =~ /\A(\/[\w]+)\s*Do\z/xms) {
            my $ref = $1;
            my $xobj = $self->pdf->dereference($ref, $self->pageno);
            my $objnum = $xobj->{objnum};
            my $im = $self->pdf->getValue($xobj);
            my $image = Remedi::PDF::Page::Image->new(
                pdf => $self->pdf,
                im => $im,
            );
            push @images, $image;
        }
    }
    return \@images;
}

sub _build_text {
    my $self = shift;
   
    return $self->pdf->getPageText($self->pageno);
}

__PACKAGE__->meta->make_immutable;

1;
