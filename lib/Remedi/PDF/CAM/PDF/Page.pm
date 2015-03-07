package Remedi::PDF::CAM::PDF::Page;

# ABSTRACT: Class for a page in CAM::PDF 

use Moose;
use CAM::PDF;
use Remedi::PDF::CAM::PDF::Image;
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
    isa => 'Remedi::PDF::CAM::PDF',
    required => 1,
);

has 'pagecontent' => ( is => 'lazy', isa => Str );
has 'parts'       => ( is => 'lazy', isa => ArrayRef[Str] );
has 'images' => (
    traits => ['Array'],
    is => 'lazy', 
    isa => 'ArrayRef[Remedi::PDF::CAM::PDF::Image]',
    handles => {
        all_images   => 'elements',
        count_images => 'count',
        sort_images  => 'sort', 
    }     
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
            my $image = Remedi::PDF::CAM::PDF::Image->new(
                pdf => $self->pdf,
                im => $im,
                objnum => $objnum,
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

sub extra_images {
    my $self = shift;
   
    my ($main_image, @xt_images) = $self->sort_images(sub{$_[1]->area <=> $_[0]->area});

    # foreach my $xt_image (@xt_images) {
    #    $self->pdf->_pdf->deleteObject($xt_image->objnum);  
    # }
    return scalar @xt_images;
}

__PACKAGE__->meta->make_immutable;

1;
