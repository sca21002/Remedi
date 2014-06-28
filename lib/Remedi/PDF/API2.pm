package Remedi::PDF::API2;

# ABSTRACT: Class for PDF::API2 

use Carp qw(confess);
use Moose;
use MooseX::AttributeShortcuts;
use MooseX::Types -declare => [qw(PdfApi2)];
use PDF::API2;
use aliased 'Remedi::PDF::API2::Page';
use aliased 'Remedi::PDF::Pagelabel';
use aliased 'Remedi::PDF::Pagelabels';
use Remedi::Types qw(ArrayRef File Int Maybe Str);
use Try::Tiny;
use namespace::autoclean;

class_type PdfApi2, {class => 'PDF::API2'};

has 'file' => ( is => 'rw', isa => File, coerce => 1 );

has '_pdf' => ( is => 'rw', isa => PdfApi2, lazy => 1, builder => 1,
    handles => [ qw(
        info pages image_jpeg image_tiff corefont release saveas
    )],
);

has 'size' => ( is => 'lazy', isa => Int );

has 'pagelabels' => ( is => 'lazy', isa => Maybe[Pagelabels] );

sub _build__pdf {
    my $self = shift;
    
    PDF::API2->new();
}

sub _build_size { return -s (shift)->file; }

sub open {
    my ($class, %param) = @_;
    
    return unless exists $param{file};
    
    my $self = $class->new();
    $self->file($param{file});
    try {
        $self->_pdf(PDF::API2->open($self->file));
    } catch {
        confess "Couldn't open PDF file '" . $self->file . "': $_";
    };
    return $self;
}

sub _build_pagelabels {
    my $self = shift;
    
    return unless exists $self->_pdf->{catalog}->{PageLabels};
    my $PageLabels = $self->_pdf->{catalog}->{PageLabels};
    if ( ref($PageLabels) =~ /Objind$/ ) {
        $PageLabels->realise;    
    }
    return unless $PageLabels->{Nums};
    my $label_array = $PageLabels->{Nums}->val;
    my $pagelabels = Remedi::PDF::Pagelabels->new(
        number_of_pages => $self->pages);
    while ( my($PDF_Number, $PDF_Dict) = splice( @$label_array, 0, 2 ) ) {
        my $label = { page_no => $PDF_Number->val }; 
        if ( ref($PDF_Dict) =~ /Objind$/ ) {
            $PDF_Dict->realise
        }
        my @keys      = Pagelabel->keys();
        my %key_map   = Pagelabel->key_map;     # maps short to long keys
        my %style_map = Pagelabel->style_map;   # maps short to long style names
        foreach my $key (@keys) {
            if ( exists $PDF_Dict->{$key} ) {
                my $label_key = $key_map{$key};
                my $val = $PDF_Dict->{$key}->val;
                $label->{ $label_key } = $key eq 'S' ? $style_map{$val} : $val;
            }
        }
        $pagelabels->add(Pagelabel->new($label));        
    }
    return $pagelabels;
}

sub page { Page->new(_page => (shift)->_pdf->page(@_) ) }

sub openpage { Page->new(_page => (shift)->_pdf->openpage(@_)) }

sub importPageIntoForm {
    my $self = shift;
    my $source_pdf = shift;
    
    confess("1st argument must be Remedi::PDF::API2 instance"
        . ' not: ' . ref $source_pdf)
        unless ref $source_pdf eq 'Remedi::PDF::API2';
    $self->_pdf->importPageIntoForm($source_pdf->_pdf, @_);
}

__PACKAGE__->meta->make_immutable;

1;
