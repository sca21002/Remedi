package Remedi::Excel;

# ABSTRACT: Class for a Excel file

use Moose;
    with qw(
        Remedi
        Remedi::Log
        MooseX::SimpleConfig
        MooseX::Getopt
        MooseX::Log::Log4perl
    );
use MooseX::AttributeShortcuts;
use Path::Tiny qw(path);
use Remedi::Types qw(ArrayRefOfRemediFile Dir File Path RemediFile Str);
use Excel::Template;
use namespace::autoclean;

has 'excel_dirname'  => ( is => 'ro', isa => Path, coerce => 1, default => '.');
has '_excel_dir' => ( is => 'lazy', isa => Dir );

has 'ingest_reference_files' => (
    is => 'lazy', isa => ArrayRefOfRemediFile,
);

has '_name'          => ( is => 'ro', isa => Str, default => 'Excel');

has '_xml_config_file' => ( is => 'lazy', isa => File );

sub BUILD { 
    my $self = shift;    

    $self->log;    # init logging
} 


sub _build__excel_dir {
    my $self = shift;
     
    my $excel_dir = path( $self->working_dir, $self->excel_dirname );
    $excel_dir->mkpath;
    return $excel_dir 
}


sub _build_ingest_reference_files {
    my $self = shift;
    
    my @imagefiles =
        grep {$_->basename =~ $self->regex_suffix_reference}
            @{$self->ingest_files};
    foreach my $file (@imagefiles) {
        $self->log->trace($file->basename);    
    }
    return \@imagefiles;
}

sub _build__xml_config_file { path( shift->configfile->parent, 'excel.xml' ) }

sub make_excel {
    my $self = shift;    

    my $log = $self->log;
    my $template = Excel::Template->new(
        filename => $self->_xml_config_file->stringify,
    );
    $log->trace("Template: " . $self->_xml_config_file);
    $log->info("Ingest-Verzeichnis: " . $self->_ingest_dir);
    my @values = map { { columns => [ {value  => $_->basename} ] } }
        @{ $self->ingest_reference_files };
    my $order_id = $self->ingest_reference_files->[0]->order_id;
    my $worksheet = $order_id;
    $template->param(worksheet => $worksheet, values => \@values);
    my $excel_file = path($self->_excel_dir, $order_id . '.xls');
    $log->logdie("Program stopped! $excel_file already exists!"
    ) if $excel_file->exists;
    $log->trace("Excel file: $excel_file");    
    $template->write_file($excel_file->stringify);
}

__PACKAGE__->meta->make_immutable;

1;
