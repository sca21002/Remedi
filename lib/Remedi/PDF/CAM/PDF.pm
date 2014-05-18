package Remedi::PDF::CAM::PDF;

# ABSTRACT: Class for a pdf based on CAM::PDF 

use Moose;
use CAM::PDF;
use MooseX::AttributeShortcuts;
use MooseX::Types::Path::Tiny qw(File);
use MooseX::Types::Moose qw(Any Int Str);
use namespace::autoclean;

has 'file' => (
    is => 'ro',
    isa => File,
    required => 1,
    coerce => 1,
);

has 'pdfinfo'    => ( is => 'lazy', isa => Any );
has 'pdfversion' => ( is => 'lazy', isa => Str );
has 'size'       => ( is => 'lazy', isa => Int );

has '_pdf'       => ( is => 'lazy', isa => 'CAM::PDF',
    handles => [ qw(dereference getPageContent getPageText getValue numPages)],
);

sub _build_size {
    my $self = shift;
    
    return length $self->_pdf->{content};
}

sub _build_pdfinfo {
    my $self = shift;
    
    my $pdfinfo = $self->_pdf->{trailer}->{Info};
    $pdfinfo &&= $self->_pdf->getValue($pdfinfo);
    my %info = map { $_, $pdfinfo->{$_}->{value} } keys %$pdfinfo;
    return \%info;
}

sub _build_pdfversion {
    my $self = shift;
    
    return $self->_pdf->{pdfversion};
}

#sub _build_pages {
#    my $self = shift;
#    
#    my @pages;
#    foreach my $pageno (1 .. $self->numPages) {
#        my $page = Remedi::PDF::Page->new(
#            pdf => $self->_pdf,
#            pageno => $pageno
#        );
#        push @pages, $page;
#    }
#    return \@pages;
#}

sub _build__pdf {
    my $self = shift;
    
    return CAM::PDF->new($self->file->stringify);
}

__PACKAGE__->meta->make_immutable;

1;