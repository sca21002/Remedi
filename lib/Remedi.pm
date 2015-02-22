use utf8;
package Remedi;

# ABSTRACT: A suite of tools to prepare digital objects for digital.bib-bvb.de 

use Moose::Role;

use Carp qw(confess);
use List::Util qw(first);
use Log::Log4perl qw(:levels);
use Log::Log4perl::Util::TimeTracker;
use MooseX::AttributeShortcuts;
use Path::Tiny qw(path);
use Remedi::Imagefile::Archive;
use Remedi::Imagefile::Reference;
use Remedi::Imagefile::Thumbnail;
use Remedi::RemediFile;
use Remedi::Imagefile::Ocr;
use Remedi::Types qw(
    ArrayRef ArrayRefOfImagefile ArrayRefOfRemediFile Bool B3KatID DateTime
    Dir File HashRef Imagefile ISIL Library_union_id Int LogLevel 
    MaybeRemediFile NonEmptyDoubleStr NonEmptySimpleStr Num Path PositiveInt 
    RemediFile RemediRegexpRef Str ThumbnailFormat TimeTracker URN_level Usetype
);
use Remedi::Units;
use namespace::autoclean;

sub get_logfile_name {
    my $path = path( Path::Tiny->tempdir, 'remedi.log' );
    $path->touchpath;    # doesn't work in one chained instruction, only Win32?
    return $path->stringify;
}

has 'archive_path' => ( is => 'ro', isa => Path, predicate => 1, coerce => 1 );

has '_archive_dir' => ( is => 'lazy', isa => Dir, predicate => 1 );

has 'archive_files' => (
    is => 'lazy', isa => ArrayRefOfImagefile, predicate => 1 );

has 'author'        => ( is => 'ro', isa => NonEmptySimpleStr, predicate => 1 );

has 'bv_nr'            => ( is => 'rw', isa => B3KatID  );

has 'create_date'      => (is => 'ro', isa => DateTime, predicate => 1);

has 'creator'        => ( is => 'ro', isa => NonEmptySimpleStr, predicate => 1);

has 'creator_pdf_info' => ( is => 'lazy', isa => NonEmptySimpleStr );

has 'image_path' => ( is => 'ro', isa => Path, coerce => 1, default => '.' );

has 'image_basepath' => ( is => 'ro', isa => Path, coerce => 1, default => '.');

has '_ingest_dir' => ( is => 'lazy', isa => Dir );

has 'ingest_files' => ( is => 'lazy', isa => ArrayRefOfRemediFile );

has 'ingest_path' => ( is => 'ro', isa => Path, predicate => 1, coerce => 1 );

has 'isil' => ( is => 'ro', isa => ISIL );

has 'job_file' => ( is => 'lazy', isa => MaybeRemediFile );  

has 'library_union_id' => ( is => 'ro', isa => Library_union_id, required => 1);

has 'log_configfile' => ( is => 'lazy', isa => Path, coerce => 1);

has 'log_file' => ( is => 'lazy', isa => Path );

has 'log_level' => ( is => 'lazy', isa => LogLevel, coerce => 1 );

has '_ocr_dir' => ( is => 'lazy', isa => Dir, , predicate => 1 );

has 'ocr_files' => ( is => 'lazy', isa => ArrayRefOfRemediFile, predicate => 1);

has 'ocr_path' => ( is => 'ro', isa => Path, predicate => 1, coerce => 1 );

has 'order_id' => ( is => 'lazy', isa => NonEmptySimpleStr );

has 'pages_total' => ( is => 'lazy', isa => PositiveInt, init_arg => undef );

has 'profile' => ( is => 'ro', isa => Bool, default => 1 );

has 'reference_dir' => ( is => 'lazy', isa => Dir, predicate => 1, coerce => 1 );

has 'reference_files' => (
    is => 'lazy', isa => ArrayRefOfImagefile, predicate => 1 );

has 'reference_path' => ( is => 'ro', isa => Path, predicate => 1, coerce => 1);

has 'regex_filestem_prefix' =>(
    is => 'ro', isa => RemediRegexpRef, coerce => 1, required => 1 );

has 'regex_filestem_var' => (
    is => 'ro', isa => RemediRegexpRef, coerce => 1, required => 1 );

has 'regex_suffix_archive' =>(
    is => 'lazy', isa => RemediRegexpRef, coerce => 1 );

has 'regex_suffix_job' =>(
    is => 'lazy', isa => RemediRegexpRef, coerce => 1 );

has 'regex_suffix_ocr' =>(
    is => 'lazy', isa => RemediRegexpRef, coerce => 1 ); 

has 'regex_suffix_reference'=>(
    is =>'lazy', isa => RemediRegexpRef, coerce => 1 );

has 'shelf_number' => ( is => 'ro', isa => Str, predicate => 1 ); 

has 'size_class_border'   => (
    is => 'ro', isa => Num, default => 150 * pt_pro_mm ); 

has 'sRGB_profile' => ( is => 'lazy', isa => File, coerce => 1 );

has 'tempdir' => ( is => 'lazy', isa => Dir );

has '_thumbnail_dir'     => ( is => 'lazy', isa => Dir, predicate => 1 );

has 'thumbnail_files' => ( 
    is => 'lazy', isa => ArrayRefOfImagefile, predicate => 1 );

has 'thumbnail_format' => (
    is => 'ro', isa => ThumbnailFormat, default => 'GIF' );

has 'thumbnail_path' => ( is => 'ro', isa => Path, predicate => 1, coerce => 1);

has 'thumbnail_width' => ( is => 'ro', isa => PositiveInt, default => 300 );

has '_timer' => ( is => 'lazy', isa => TimeTracker );

has 'title' => ( is => 'ro', isa => NonEmptyDoubleStr, required => 1 );

has 'urn_level' => ( is => 'ro', isa => URN_level, default => 'single_page' );

has 'working_dir' => ( is => 'lazy', isa => Dir, init_arg => undef );

has 'year_of_publication' => (
    is => 'ro', isa => NonEmptySimpleStr, predicate => 1 );

sub BUILD {
    my $self = shift;
    
    $self->init_logging(@_);
}

sub config_any_args { { driver_args => { General => { '-UTF8' => 1 } } } }


sub _build__archive_dir {
    my $self = shift;
    
    my $archive_dir = $self->_makedir( 'archive' );
    $self->log->info('Directory of archive files: ' . $archive_dir);
    if ( $archive_dir->children ) {
        $self->log->info('Archive directory already exists and has images');    
    } else {
        $self->_prepare_dir($archive_dir, $self->regex_suffix_archive);
    }
    return $archive_dir;
}

sub _build_archive_files {
    my $self = shift;
    
    my $archive_dir = $self->_archive_dir;
    my @list = sort grep {!/Thumbs\.db$/i} $archive_dir->children;
    $self->log->logcroak("No image files in $archive_dir") unless @list;
    
    my @imagefiles = map {
        Remedi::Imagefile::Archive->new(
            file => $_,
            isil => $self->isil,
            library_union_id => $self->library_union_id,
            profile => $self->profile,
            regex_filestem_prefix => $self->regex_filestem_prefix,
            regex_filestem_var => $self->regex_filestem_var,
            size_class_border => $self->size_class_border,
            sRGB_profile => $self->sRGB_profile,
            tempdir => $self->tempdir,
                                # we pass it to have one tempdir for all files
            thumbnail_format => $self->thumbnail_format,
            thumbnail_width => $self->thumbnail_width,
        )
    } @list;
    $self->log->info('Number of archive files: ' . scalar @list);
    return \@imagefiles;
}

sub _build_creator_pdf_info {
    my $self = shift;
    
    confess ("Attribute 'creator' is not set while building creator_pdf_info")
        unless $self->has_creator;
    return 'Digitalisiert von der ' . $self->creator;
}

sub _build__ingest_dir {
    my $self = shift;
    
    my $ingest_dir = $self->_makedir( 'ingest' );
    $ingest_dir->mkpath;                     # created unless it already exists  
    return $ingest_dir
}

sub _build_ingest_files {
    my $self = shift;
    
    my $log = $self->log;
    my $ingest_dir = $self->_ingest_dir;
    my @list = sort grep {!/Thumbs\.db$/i} $ingest_dir->children;
    $log->logcroak('No Imagefiles in '. $ingest_dir->absolute) unless @list;     
    my @imagefiles = map {
        Remedi::RemediFile->new(
            isil => $self->isil,
            library_union_id => $self->library_union_id,
            regex_filestem_prefix => $self->regex_filestem_prefix,
            regex_filestem_var => $self->regex_filestem_var,
            file => $_->stringify,
        )
    } @list;
    $log->info('Number of ingest files: ' . scalar @list);
    return \@imagefiles;
}

sub _build_job_file {
    my $self = shift;

    my $regex = $self->order_id .  $self->regex_suffix_job;
    my @files = $self->working_dir->children(qr/$regex/);
    $self->logcroak('More than one job file found') if @files > 1;
    if ( @files && $files[0]->is_file ) { 
        my $job_file = Remedi::RemediFile->new(
            isil => $self->isil,
            library_union_id => $self->library_union_id,
            regex_filestem_prefix => $self->regex_filestem_prefix,
            regex_filestem_var => $self->regex_filestem_var,
            file => $files[0],
        );
        $self->log->info('job file: ' . $job_file->stringify);
        return $job_file;
    } else {
        $self->log->info('No job file found');
        return;    
    }
}

sub _build_log_file {
    my $self = shift;
    
    return path($self->working_dir, 'remedi.log'); 
}

sub _build_log_configfile {
    my $self = shift;
        
    if ($self->configfile) {
        return $self->configfile->parent->child('log4perl.conf');
    } else {
        return path(__FILE__)->parent->child( qw( Remedi config log4perl.conf));    
    }
}

sub _build_log_level { $INFO } 

sub _build__ocr_dir {
    my $self = shift;
    
    my $ocr_dir = $self->_makedir( 'ocr' );
    $self->log->info('Directory of OCR files: ' . $ocr_dir);
    unless ($ocr_dir->is_dir && $ocr_dir->children) {
        $self->_prepare_dir($ocr_dir, $self->regex_suffix_ocr);
    }
    else { $self->log->info('OCR directory already exists'); }
    return $ocr_dir;
}

sub _build_ocr_files {
    my $self = shift;
    
    my $ocr_dir = $self->_ocr_dir;
    my @list = sort grep {!/Thumbs\.db$/i} $ocr_dir->children;
    $self->log->logcroak("No ocr files in $ocr_dir") unless @list;
    
    my @ocrfiles = map {
        Remedi::Imagefile::Ocr->new(
            regex_filestem_prefix => $self->regex_filestem_prefix,
            regex_filestem_var => $self->regex_filestem_var,
            file => $_,
        )
    } @list;
    $self->log->info('Number of OCR files: ' . scalar @list);
    return \@ocrfiles;
}

sub _build_order_id { (shift)->archive_files->[0]->order_id }

sub _build_reference_dir {
    my $self = shift;
    
    my $reference_dir = $self->_makedir( 'reference' );
    $reference_dir->mkpath;                 # created unless it already exists  
    return $reference_dir
}

sub _build_reference_files {
    my $self = shift;
    
    my $log = $self->log;
    my $reference_dir = $self->reference_dir;
    my @list = sort grep {!/Thumbs\.db$/i} $reference_dir->children;
    $log->logcroak('No Imagefiles in ' . $reference_dir->absolute)
        unless @list;     
    my @imagefiles = map {
        Remedi::Imagefile::Reference->new(
            isil => $self->isil,
            library_union_id => $self->library_union_id,
            regex_filestem_prefix => $self->regex_filestem_prefix,
            regex_filestem_var => $self->regex_filestem_var,
            size_class_border => $self->size_class_border,
            file => $_
        )
    } @list;
    return \@imagefiles;
}

sub _build_regex_suffix_archive {
    qr{
        \.              # '.' as separator
        (?:             # 
          tiff?         # tif(f)
          |             # or
          jpg           # JPEG
          |             # or
          jp2           # JPEG 2000
        )               #  
        \z              # .. to the end            
    }ixms;
}

sub _build_regex_suffix_job {
    qr{
        \.              # '.' as separator
        job             # job
        \z              # .. to the end            
    }ixms;
}

sub _build_regex_suffix_ocr {
    qr{
        \.              # '.' as separator
        xml             # xml
        \z              # .. to the end            
    }ixms;
}

sub _build_regex_suffix_reference {
    qr{
        \.              # '.' as separator
        (?:             # clustering not capturing
        pdf             # pdf
        |               # ...or
        jp2             # jp2
        )
        \z              # .. to the end            
    }ixms;
}

sub _build_pages_total {
    my $self = shift;
    
    return scalar @{$self->archive_files};
}

sub _build_sRGB_profile {
    path(__FILE__)->parent(2)->child(
        qw( color sRGB_Color_Space_Profile.icm )
    );
}

sub _build_tempdir { Path::Tiny->tempdir() }

sub _build__thumbnail_dir {
    my $self = shift;
    
    my $thumbnail_dir = $self->_makedir( 'thumbnail' );
    $thumbnail_dir->mkpath;                  # created unless it already exists 
    return $thumbnail_dir
}

sub _build_thumbnail_files {
    my $self = shift;

    my $log = $self->log;
    my $thumbnail_dir = $self->_thumbnail_dir;
    my @list = sort grep {!/Thumbs\.db$/i} $thumbnail_dir->children;
    $log->logcroak('No Imagefiles in ' . $thumbnail_dir->absolute)
        unless (@list);     
    my @imagefiles = map {
        Remedi::Imagefile::Thumbnail->new(
            isil => $self->isil,
            library_union_id => $self->library_union_id,
            regex_filestem_prefix => $self->regex_filestem_prefix,
            regex_filestem_var => $self->regex_filestem_var,
            size_class_border => $self->size_class_border,
            file => $_
        )
    } @list;
    return \@imagefiles;
}

sub _build__timer { Log::Log4perl::Util::TimeTracker->new() }

sub _build_working_dir {
    my $self = shift;
    
    return path($self->image_basepath, $self->image_path);
}

sub finish {
    my $self = shift;
    
    my $dt = DateTime::Duration->new(
        nanoseconds => $self->_timer->milliseconds * 1E6
    );
    
    $self->log->info(
        "Laufzeit [hh:mm:ss]: "
        . sprintf("%02d:%02d:%02d", $dt->in_units('hours','minutes','seconds'))
    );
    $self->log->info(sprintf("----- End: %s -----", $self->_name) );
}

sub init_logging {
    my ($self, $args) = @_;
    
    $self->_timer->reset;
    my ($debug_msg, $warn_msg);
    if ( $self->log_configfile->is_file ) {
        Log::Log4perl->init_once( $self->log_configfile->stringify );
        my $appender = Log::Log4perl->appender_by_name('LOGFILE');
        $appender->file_switch($self->log_file->stringify)
            if $appender;
        $debug_msg = sprintf("log config file: '%s'", $self->log_configfile);  
    } else {
        Log::Log4perl->easy_init($Log::Log4perl::INFO);
        $warn_msg = sprintf("log config '%s' not found", $self->log_configfile);
        $warn_msg .= "\nInit easy logging mode";     
    }
    $self->log->level($self->log_level);
    $self->log->debug($debug_msg) if  $debug_msg;
    $self->log->warn($warn_msg) if  $warn_msg;
    $self->log->debug("Log file: " . $self->log_file->stringify);
    $self->log->info(sprintf("----- Start: %s -----", $self->_name));
    $self->log->info("Title: ", $self->title); 
    $self->log->debug("----- Parameters -------------");
    foreach my $key  (sort grep { !/usage|app|log_level/ } keys %$args) {
    	$self->log->debug( sprintf("      %s => %s",$key, $args->{$key} ) );
    }
    $self->log->debug( sprintf("      %s => %s",
        'log_level',
        Log::Log4perl::Level::to_level( $self->log_level ),
    ) );
    $self->log->debug("----- End parameters --------");
    $self->log->info("Working directory: " . Cwd::cwd() );
}

sub _makedir {
    my ($self, $type) = @_;
    
    my $path;
    my $attr = $type . '_path';
    my $predicate = 'has_' . $attr;
    if ($self->$predicate) {
        $path = $self->$attr;
        if ($path->is_absolute) {
            $path->mkpath;
            return $path;
        } 
    }
    $path = $type unless $path;
    my $dir = path( $self->working_dir, $path );
    $dir->mkpath;
    return $dir;
}

sub _prepare_dir {
    my $self         = shift;
    my $dir          = shift;
    my $regex_suffix = shift;
    
    my $regex = $self->regex_filestem_prefix
              . $self->regex_filestem_var
              . $regex_suffix
              ;
    my @imagefiles = sort grep { /$regex/ } $self->working_dir->children;
                                                        # sort not mandatory
    $self->log->logcroak( sprintf(
        "No files in '%s' with pattern $regex", $self->working_dir
    ) ) unless (@imagefiles);
    foreach my $imagefile (@imagefiles) {
        $imagefile->copy($dir);
        $imagefile->remove;
    }
}

sub set_init_args {
    my ($self, $init_args, $attrib) = @_;
    
    my $predicate = 'has_' . $attrib;
    $init_args->{$attrib} = $self->$attrib if $self->$predicate;    
} 

no Remedi::Units;
1; # Magic true value required at end of module

__END__

=attr archive_path (default C<archive>)

A path of a temporary directory to collect the files of type archive.
If a relative path is given the directory will be created relative to
C<working_dir>

=attr archive_files

List of archive files

=attr author

Author of the original work.
Used in the metadata of the PDF files and in the METS document

=attr bv_nr

Identifier of the original work in the B3Kat joint union catalogue 

=attr create_date

Creation date of the digital object
Default value is the time when running this program.
Used in the metadata of the PDF files and in the METS document


=attr creator

Creator of the digital object, e.g. the digitising institution 
Used in the metadata of the PDF files and in the METS document

=attr creator_pdf_info

Clause describing the digital object as created from digitising by the creator
Used in the metadata of the PDF files

=attr image_path

Path relative to image_basepath
Combined with image_basepath it builds C<working dir>, the base path of the
digital object.
Typically it includes an identifier, e.g the order id, to indentify the actual
digital object  

=attr image_basepath

Base path of all the digital objects

=attr ingest_path (default: C<ingest>)

In this directory all files are finally collected for the ingest.
If a relative path is given the directory will be created relative to
C<working_dir>

=attr ingest_files

List of files prepared for the ingest

=attr isil

International Standard Identifier for Libraries and Related Organisations (ISIL)
of the digitising library

=attr library_union_id

Short cut of the library union, to which the digitising library belongs
This identifier is used as part of the URN

=attr log_configfile

Configuration file for logging
If not set a file named C<log4perl.conf> is first searched in the same
directory, where the C<config_file> is located, if not found then in
C<./Remedi/config>.

=attr log_file

Path of the log_file
If the given path is relative it will be created relative to C<working_dir>

=attr log_level (default: INFO)

Logging level
Possible values are OFF, FATAL, ERROR, WARN, INFO, DEBUG, TRACE, ALL

=attr profile (default: on)

If set images are converted into the C<standard RGB color space> (sRGB) 

=attr ocr_path (default: C<ocr>)

A path of a temporary directory to collect the files with the OCR results.
If a relative path is given the directory will be created relative to
C<working_dir>

=attr ocr_files

List of OCR files

=attr order_id (required)

Identifier for the digital object 

=attr pages_total

Number of pages of the digital object.
Calculated from the number of archive files 

=attr reference_path (default: C<reference>)

A path of a temporary directory to collect the files of type reference.
If a relative path is given the directory will be created relative to
C<working_dir>

=attr regex_filestem_prefix

Regular expression for the invariant part of the file names

=attr regex_filestem_var

Regular expression for the part of the file names, which indentifies and orders
a file in a set of files

=attr regex_suffix_archive

Regular expression to identify a file as a archive file 

=attr regex_suffix_ocr

Regular expression to identify a file as a OCR file

=attr regex_suffix_reference

Regular expression to identify a file as a reference file

=attr shelf_number

Shelf number of the original work
Used in the metadata of the PDF files and in the METS document

=attr size_class_border

Books with a height over this value are classified as large 


=attr sRGB_profile

Path to the profile file of the sRGB color space

=attr tempdir

A temporary directory

=attr thumbnail_path (default: C<thumbnail>)

A path of a temporary directory to collect the files of type archive.
If a relative path is given the directory will be created relative to
C<working_dir>

=attr thumbnail_files

List of thumbnail files

=attr thumbnail_format

Image file format of the thumbnails

=attr thumbnail_width

Width of the thumbnail images

=attr title

Title of the digitised work
Used in the metadata of the PDF files and in the METS document

=attr urn_level (default: single_page)

Defines to what extent URNs should be applied to the digital entities.
Possible values are no_urn, object, and single_page

=attr working_dir

Base directory for the digital object.
It can't be set directly, but is combined from C<image_bathpath> and
C<image_path>

