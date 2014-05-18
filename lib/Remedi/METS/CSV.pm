use utf8;
package Remedi::METS::CSV;

# ABSTRACT: Class for reading csv files

use Moose;
    with 'MooseX::Log::Log4perl';

use MooseX::AttributeShortcuts;
use Remedi::Types qw(ArrayRefOfMaybeSimpleStr File);    
use Text::CSV_XS;
use Data::Dumper;
use namespace::autoclean;

has 'csv_file' => ( is => 'ro', isa => File, required => 1, coerce => 1 );

has 'sequence_of_labels' => (
    is => 'lazy',
    isa => ArrayRefOfMaybeSimpleStr,
    traits => ['Array'],
    handles => {
        labels => 'elements',
    },
);    

sub _build_sequence_of_labels {
    my $self = shift;
    
    my @rows = $self->read_csv;
    my $header = shift(@rows);
    $self->log->logdie( sprintf(
        "No valid CSV file '%s'. header expected, but '%s' found instead",
        $self->csv_file, join(';', @$header)
    ) ) unless $header->[0] eq 'Dateiname';
    return [ map { $_->[1] } @rows ];
}

sub read_csv {
    my $self = shift;
    
    my $csv_file = $self->csv_file;
    my $csv = Text::CSV_XS->new ({ binary => 1 }) or
        $self->log->logdie("Cannot use CSV: " . Text::CSV->error_diag ());
    $csv->sep_char(";");
    $self->log->trace("CSV-Datei: " . $csv_file);
    open my $fh, "<:encoding(cp1252)", $csv_file->stringify
        or $self->log->logdie("$csv_file: $!");
    my @rows;
    while (my $row = $csv->getline ($fh)) {
        push @rows, $row;
    }
    $csv->eof or $csv->error_diag;
    close $fh or $self->log->logdie("$csv_file: $!");
    return @rows;
}

__PACKAGE__->meta->make_immutable;

1;
