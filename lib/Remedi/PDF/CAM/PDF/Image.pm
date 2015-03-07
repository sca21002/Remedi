package Remedi::PDF::CAM::PDF::Image;

# ABSTRACT: Class for a image in CAM::PDF 

use Moose;
use CAM::PDF;
use MooseX::AttributeShortcuts;
use namespace::autoclean;
use Remedi::Types qw(Int Str);


has 'area'             => ( is => 'lazy', isa => Int );
has 'bits_per_component' => ( is => 'lazy', isa => Int );
has 'colorspace'       => ( is => 'lazy', isa => Str );
has 'filter'           => ( is => 'lazy', isa => Str );
has 'height'           => ( is => 'lazy', isa => Int );
has 'length'           => ( is => 'lazy', isa => Int );
has 'objnum'           => ( is => 'ro'  , isa => Int, required => 1 );
has 'name'             => ( is => 'lazy', isa => Str );
has 'subtype'          => ( is => 'lazy', isa => Str );
has 'type'             => ( is => 'lazy', isa => Str );
has 'width'            => ( is => 'lazy', isa => Int );

has 'pdf' => (
    is => 'ro',
    isa => 'Remedi::PDF::CAM::PDF',
    required => 1,
);

has 'im' => (
    is => 'ro',
    isa => 'HashRef[CAM::PDF::Node]',
    required => 1,
);

sub _build_area {
    my $self = shift;

    return $self->height * $self->width;
}

sub _build_bits_per_component  {
    my $self = shift;    

    my $bpc = $self->im->{BitsPerComponent} || 0;
    $bpc &&= $self->pdf->getValue($bpc);
    return $bpc; 
}

sub _build_colorspace  {
    my $self = shift;    

    my $csp = $self->im->{ColorSpace} || '';
    $csp &&= $self->pdf->getValue($csp);
    return $csp; 
}

sub _build_filter  {
    my $self = shift;    

    my $f = $self->im->{Filter} || '';
    $f &&= $self->pdf->getValue($f);
    return $f; 
}


sub _build_height  {
    my $self = shift;    

    my $h = $self->im->{Height} || $self->im->{H} || 0;
    $h &&= $self->pdf->getValue($h);
    return $h;   
}


sub _build_length  {
    my $self = shift;    

    my $l = $self->im->{Length} || $self->im->{L} || 0;
    $l &&= $self->pdf->getValue($l);
    return $l;   
}


sub _build_name  {
    my $self = shift;    

    my $n = $self->im->{Name} || '';
    $n &&= $self->pdf->getValue($n);
    return $n;    
}


sub _build_subtype  {
    my $self = shift;    
    
    my $stp = $self->im->{SubType} || '';
    $stp &&= $self->pdf->getValue($stp);
    return $stp;   
}


sub _build_type  {
    my $self = shift;    
    
    my $tp = $self->im->{Type} || '';
    $tp &&= $self->pdf->getValue($tp);
    return $tp;   
}


sub _build_width  {
    my $self = shift;    
    
    my $w = $self->im->{Width} || $self->im->{W} || 0;
    $w &&= $self->pdf->getValue($w);
    return $w;   
}

__PACKAGE__->meta->make_immutable;

1;
