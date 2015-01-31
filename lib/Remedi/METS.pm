use utf8;
package Remedi::METS;

# ABSTRACT: Role for METS

use Moose::Role;

use DateTime;
use File::Copy;
use Modern::Perl;
use MooseX::AttributeShortcuts;
use Path::Tiny;
use PDF::API2;
use Remedi::METS::CSV;
use Remedi::Document::Standard;
use Remedi::Document::Thesis::DC;
use Remedi::Document::Thesis::MARC;
use Remedi::PDF::ExifTool::Info;
use Remedi::Types qw(ArrayRefOfUsetype Bool DateTime Lang MetadataFormat
    NonEmptySimpleStr Path RemediMETSCSV Str);
use XML::Toolkit::App;
use Data::Dumper;
use namespace::autoclean;

has 'bibliographic_metadata_format' => (
    is => 'ro',
    isa => MetadataFormat,
    default => 'MARC',
);

has 'csv' => ( is => 'lazy', isa => RemediMETSCSV );

has 'is_thesis_workflow'  => ( is => 'ro', isa => Bool, default => 0 );

has 'lang' => ( is => 'ro', isa => Lang, default => 'ger' );

has 'mets_file' => ( is => 'lazy', isa => Path );

has 'mets_label' => ( is => 'lazy', isa => Str );

has '_name' => ( is => 'ro', isa => Str, default => 'METS' );

has 'print_source_holder' => (
    is => 'ro', isa => NonEmptySimpleStr, required => 1
);


has 'usetypes' => ( is => 'ro', isa => ArrayRefOfUsetype,
    default => sub { [qw(archive reference thumbnail)] } );

has 'with_pagelabel' => ( is => 'ro', isa => Bool, default => 0 );

has 'year_of_digitisation' => ( is => 'ro', isa => NonEmptySimpleStr,
    default => sub {DateTime->now->year });

sub _build_csv {
    my $self = shift;

    my $csv = Remedi::METS::CSV->new(
        csv_file => path( $self->working_dir, $self->order_id . '.csv' )
    );
}

sub _build_mets_file {
    my $self = shift;
    
    path( $self->working_dir, $self->order_id . '.xml' );    
}

# Volltext // Jahr digitalisiert von: Bibliothek XY. Exemplar mit der Signatur:
#  Ort, Bibliothek XY -- AB 1234

sub _build_mets_label {
    my $self = shift;
   
    my $mets_label =
        'Volltext // '
        . $self->year_of_digitisation 
        . ' digitalisiert von: ' . $self->creator . '.'
        . ' Exemplar';
    $mets_label .= ' mit der Signatur' if $self->shelf_number;
    $mets_label .= ': ' . $self->print_source_holder;
    $mets_label .= ' -- ' . $self->shelf_number if $self->shelf_number;
    return $mets_label;
}

sub get_usetype_file_map {
    my $self = shift;
 
    my %usetype_file_map;
    foreach my $usetype ( @{$self->usetypes} ) {
        my $usetype_files = $usetype . '_files';
        $usetype_file_map{$usetype_files} = $self->$usetype_files; 
    }
    return %usetype_file_map;
}

sub get_usetype_files {
    my $self = shift;
    
    my %file_map = $self->get_usetype_file_map;
    return map { @{ $file_map{$_ . '_files'} } } @{$self->usetypes};
}

sub move_files_to_ingestdir {
    my $self = shift;
    
    foreach my $usetype_file ($self->get_usetype_files) {
        my $ingest_file = path($self->_ingest_dir, $usetype_file->basename);
        $self->log->info($ingest_file);
        File::Copy::move(
            $usetype_file->stringify,
            $ingest_file->stringify
        );            
    }
}

sub check_index {
    my $self = shift;

    my %map = $self->get_usetype_file_map;
    foreach my $usetype ( @{$self->usetypes} ) {
        my $index = 1;
        foreach my $imagefile ( @{ $map{ $usetype . '_files' } } ) {
            unless ($imagefile->index == 0) {
                $self->log->logdie(sprintf(
                    "Gap in numbering found for '%s': "
                    . "calculated order is %s and real order %s",
                    $imagefile->basename, $imagefile->index, $index
                )) unless  $imagefile->index == $index;
                $index++;
            }
        }
    }
}

sub make_mets {
    my $self = shift;


    my $log = $self->log;
    $log->logdie('No version info for Remedi. Eventually you started the '
        . 'program from a developer environment.') unless $Remedi::VERSION;
    $self->check_index;
    my $namespace_map = {
            ''        => 'http://www.loc.gov/METS/',
            'xsi'     => 'http://www.w3.org/2001/XMLSchema-instance',
            'xlink'   => 'http://www.w3.org/1999/xlink',
    };
    if ($self->bibliographic_metadata_format eq 'DC') {
        $namespace_map->{dc}      = 'http://purl.org/dc/elements/1.1/';
        $namespace_map->{dcterms} = 'http://purl.org/dc/terms/';    
    }

    my $generator = XML::Toolkit::App->new({
        namespace_map => $namespace_map
    })->generator;
    
    my $init_args ={          
        bv_nr                => $self->bv_nr,                # required
        is_thesis_workflow   => $self->is_thesis_workflow,   # default 0
        isil                 => $self->isil,                 # required 
        lang                 => $self->lang,                 # default
        library_union_id     => $self->library_union_id,     # required
        mets_label           => $self->mets_label,           # required
        urn_level            => $self->is_thesis_workflow
                                ? 'object' : $self->urn_level,  # default
        profile              => 0,                           # API sucks
        order_id             => $self->order_id,             # required
        title                => $self->title,                # required
        usetypes             => $self->usetypes,             # required
        year_of_digitisation => $self->year_of_digitisation, # default
    };
    foreach my $attrib ( qw(
        author
        create_date
        shelf_number
        year_of_publication
    ) ) {
        $self->set_init_args($init_args, $attrib)
    }
    $init_args->{publisher} = 'Dissertation, Universität Regensburg'
        if $self->is_thesis_workflow;     
    $init_args = { %$init_args, $self->get_usetype_file_map };
    my @sequence = $self->csv->labels;
    @sequence = ( 1 .. $self->pages_total )
        if $self->is_thesis_workflow and not grep { $_ } @sequence;    
    $init_args->{sequence} = \@sequence
        if grep { $_ } @sequence and
        ( $self->is_thesis_workflow or $self->with_pagelabel);
    $init_args->{job_file} = $self->job_file if $self->job_file;
    my $Document_class =
        $self->is_thesis_workflow
            ?   ( $self->bibliographic_metadata_format eq 'DC'
                    ?  'Remedi::Document::Thesis::DC'
                    :  'Remedi::Document::Thesis::MARC'
                )
            : 'Remedi::Document::Standard'
        ;
    my $document = $Document_class->new($init_args);
    
    $generator->render_object($document->get_mets);
    $self->move_files_to_ingestdir();
    $self->mets_file->spew_utf8($generator->output);
    $log->info($self->mets_file . " written.");
    $self->write_pdf_info($document->urn) if $self->is_thesis_workflow;
    foreach my $usetype ( @{$self->usetypes} ) {
        my $dir = '_' . $usetype . '_dir';
        my $has_dir = '_has' . $dir;
        $log->trace( sprintf( "'%s' removed", $self->$dir ) )
            if $self->$has_dir and $self->$dir->remove_tree; 
    }
    $self->finish;
    return join '', $generator->output;
}

sub copy_multipage_pdf {
    my $self = shift;
    
    my $pdf_file = path( $self->working_dir, $self->order_id . '.pdf' );
    $self->log->info($pdf_file . ' --> ' . $self->_reference_dir);
    File::Copy::move( $pdf_file, $self->_reference_dir );    
}

sub write_pdf_info {
    my ($self, $urn) = @_;
    
    my $log = $self->log;
    my $pdf_file = path( $self->_ingest_dir, $self->order_id . '.pdf' );
    
    foreach my $arg ( qw(author shelf_number year_of_publication) ) {
        my $predicate = 'has_' . $arg;
        $log->logdie("$arg is required") unless $self->$predicate;
    }
    
    my $writer = Remedi::PDF::ExifTool::Info->new({
        file                => $pdf_file,
        author              => $self->author,  
        creator             => $self->creator_pdf_info,              # default
        $self->urn_level eq 'object'  ? ( keywords => $urn ) : (),
        metadata_date       => DateTime->now(
                                locale => 'de_DE',
                                time_zone => 'Europe/Berlin',
                               ),
        publisher           => 'Dissertation, Universität Regensburg',
        shelf_number        => $self->shelf_number,
        title               => $self->title,
        bv_nr               => $self->bv_nr,
        year_of_publication => $self->year_of_publication,
    });
    $writer->write_info();    
}

no Moose::Role;
1; # Magic true value required at end of module

__END__

=attr bibliographic_metadata_format

Metadata format, e.g. DC (Dublin Core) or MARC 

=attr csv

CSV file from which the page labels are taken 

=attr is_thesis_workflow

Thesis workflow differs from the standard workflow.
Instead of a multipage PDF as source for reference files single page PDFs are
used. No URNs are put in the footer. 

=attr lang

3 letter language code for the language of the original.
Used in the stub MARC record of the standard workflow.

=attr mets_file

Path for the METS file. As default a file named (order_nr).xml in the working
dir.

=attr mets_label

Descriptive phrase put as label in the root node of the METS xml

=attr print_source_holder

Library that possesses the the original work

=attr with_pagelabel

Page labels are read from PDF file and put as LABEL attribute in the physical
structmap

=attr usetypes

List of manifestations, which should be created for the ingest

=attr year_of_digitisation

Year of the digitisation of the digital entity
