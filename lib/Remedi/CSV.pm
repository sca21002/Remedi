use utf8;
package Remedi::CSV;

# ABSTRACT: Role for CSV

use Moose::Role;

use MooseX::AttributeShortcuts;
use Remedi::Types qw(Dir Path RemediPdfApi2 Str);    
use Text::CSV_XS;
use Path::Tiny qw(path);
use Remedi::PDF::API2;
use Data::Dumper;
use namespace::autoclean;

has '_name'          => ( is => 'ro', isa => Str, default => 'CSV');
has 'csv_file'       => ( is => 'lazy', isa => Path );
has '_csv_dir'       => ( is => 'lazy', isa => Dir );
has 'csv_dirname'    => ( is => 'ro', isa => Path, coerce => 1, default => '.');
has 'source_pdf'     => ( is => 'lazy', isa => RemediPdfApi2);
has 'source_pdf_file'=> ( is => 'ro', isa => Path, predicate => 1, coerce => 1);

sub _build__csv_dir {
    my $self = shift;

    my $csv_dir = path( $self->working_dir, $self->csv_dirname );
    $csv_dir->mkpath;
    return $csv_dir
}

sub _build_csv_file {
    my $self = shift;

    return path( $self->_csv_dir, $self->order_id . '.csv' );
};

sub _build_source_pdf {
    my $self = shift;
    
    return Remedi::PDF::API2->open(file => $self->source_pdf_file);
}

sub make_csv {
    my $self = shift;   
    
    my $log = $self->log;
    my $csv_file = $self->csv_file;
    my $csv = Text::CSV_XS->new ( {binary => 1} );
    $log->info("Archive dir: " . $self->_archive_dir);
    my @values = map { [
        $self->archive_files->[$_]->basename,
        $self->has_source_pdf_file && $self->source_pdf->pagelabels
            ? $self->source_pdf->pagelabels->sequence->[$_]
            : (),
        ] }
        0 .. $#{$self->archive_files}
    ;
    my @rows;   
    #$csv->eol ("\r\n");
    $csv->eol("\n");
    $csv->sep_char(";");

    $log->trace("CSV-Datei: " . $csv_file);  
    open my $fh, ">:encoding(cp1252)", $csv_file->stringify
        or $log->logdie("$csv_file: $!");
    push @rows, [
        ('Dateiname',
        'Seite',
        'Struktur / 1. Ebene',
        'Struktur / 2. Ebene (Kapitel)',
        'Struktur / 3. Ebene (Unterkapitel)',
        'Struktur / 4. Ebene (...)'
        )
    ];
    @rows = (@rows, @values);
    $csv->print ($fh, $_) for @rows;
    close $fh or die "$csv_file: $!";
    $self->finish;
}

no Moose::Role;
1;
