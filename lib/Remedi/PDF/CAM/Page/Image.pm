package Remedi::PDF::CAM::Page::Image;

# ABSTRACT: Class for a image in CAM::PDF 

use Moose;
use CAM::PDF;
use MooseX::AttributeShortcuts;
use namespace::autoclean;
use Remedi::Types qw(Int Str);

has 'BitsPerComponent' => ( is => 'lazy', isa => Int );
has 'ColorSpace'       => ( is => 'lazy', isa => Str );
has 'Filter'           => ( is => 'lazy', isa => Str );
has 'Height'           => ( is => 'lazy', isa => Int );
has 'Length'           => ( is => 'lazy', isa => Int );
has 'Name'             => ( is => 'lazy', isa => Str );
has 'SubType'          => ( is => 'lazy', isa => Str );
has 'Type'             => ( is => 'lazy', isa => Str );
has 'Width'            => ( is => 'lazy', isa => Int );

has 'pdf' => (
    is => 'ro',
    isa => 'Remedi::PDF',
    required => 1,
);


has 'im' => (
    is => 'ro',
    isa => 'HashRef[CAM::PDF::Node]',
    required => 1,
);

sub _build_BitsPerComponent  {
    my $self = shift;    

    my $bpc = $self->im->{BitsPerComponent} || 0;
    $bpc &&= $self->pdf->getValue($bpc);
    return $bpc; 
}

sub _build_ColorSpace  {
    my $self = shift;    

    my $csp = $self->im->{ColorSpace} || '';
    $csp &&= $self->pdf->getValue($csp);
    return $csp; 
}

sub _build_Filter  {
    my $self = shift;    

    my $f = $self->im->{Filter} || '';
    $f &&= $self->pdf->getValue($f);
    return $f; 
}


sub _build_Height  {
    my $self = shift;    

    my $h = $self->im->{Height} || $self->im->{H} || 0;
    $h &&= $self->pdf->getValue($h);
    return $h;   
}


sub _build_Length  {
    my $self = shift;    

    my $l = $self->im->{Length} || $self->im->{L} || 0;
    $l &&= $self->pdf->getValue($l);
    return $l;   
}


sub _build_Name  {
    my $self = shift;    

    my $n = $self->im->{Name} || '';
    $n &&= $self->pdf->getValue($n);
    return $n;    
}


sub _build_SubType  {
    my $self = shift;    
    
    my $stp = $self->im->{SubType} || '';
    $stp &&= $self->pdf->getValue($stp);
    return $stp;   
}


sub _build_Type  {
    my $self = shift;    
    
    my $tp = $self->im->{Type} || '';
    $tp &&= $self->pdf->getValue($tp);
    return $tp;   
}


sub _build_Width  {
    my $self = shift;    
    
    my $w = $self->im->{Width} || $self->im->{W} || 0;
    $w &&= $self->pdf->getValue($w);
    return $w;   
}

__PACKAGE__->meta->make_immutable;

1;