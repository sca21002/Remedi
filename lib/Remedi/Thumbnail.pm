use utf8;
package Remedi::Thumbnail;

# ABSTRACT: Role for creating thumbnails from image or PDF files

use Moose::Role;
use Remedi::PDF::CAM::PDF;
use Path::Tiny;
use MooseX::AttributeShortcuts;

use Remedi::Types qw( Str JPEG2000List);   # TODO: better type name
use Try::Tiny;
use Data::Dumper;
use namespace::autoclean;

has 'list' => (
    is => 'ro', isa => JPEG2000List, predicate => 1, coerce => 1
);



sub create_thumbnail_from_pdf {
    my $self     = shift;
    my $pdf_file = shift;

    my $log = $self->log;
    my $pdf = Remedi::PDF::CAM::PDF->new( file => $pdf_file->file );
    my $error;
    try {
        $pdf->size;
    }    
    catch {
        $log->warn("Error with PDF: $_");
        $error = 1;
    };    
    return if $error;
    $log->info(sprintf("%s - %.1f MB", $pdf_file->file, $pdf_file->size / 1024 / 1024)); 
    my $thumbnail_file = path($self->_thumbnail_dir, $pdf_file->filestem . '.gif');
    $log->info($thumbnail_file);
    $pdf->create_thumbnail(
        $thumbnail_file,            # thumbnail path
        $self->thumbnail_height,    # thumbnail height
    );
}


sub create_thumbnail_from_image {
    my $self = shift;
    my $image_file = shift;

    my $log = $self->log;
    # thumbnail path
    my $thumbnail_file = path(
        $self->_thumbnail_dir, $image_file->filestem . '.gif'
    );
    $log->info(sprintf("%s - %.1f MB", $image_file->file, $image_file->size / 1024 / 1024));
    $log->info($thumbnail_file);
    # convert TIFF into 
    Remedi::ImageMagickCmds::create_thumbnail(
        $image_file->file,          # source file
        'GIF',                      # thumbnail format
        $thumbnail_file,            # thumbnail path
        $self->thumbnail_height,    # thumbnail height
    );
}


sub create_thumbnails {
    my $self = shift;

    my $log = $self->log;
    $log->info('Starting create_thumbnail');
    $log->info('Thumbnail height: ', $self->thumbnail_height);
    $log->debug('List: ', Dumper($self->list)) if $self->has_list;
    $self->reference_files;
    $log->info(scalar @{$self->reference_files} . " reference files found.");
    $log->info("Thumbs dir: " . $self->_thumbnail_dir);
    REF: foreach my $ref (@{$self->reference_files}) {
        $log->info($ref->basename . '(' . $ref->format . ' ' . $ref->index . ')' );
        if ($self->has_list and not exists $self->list->{$ref->index}) {
            $log->info('Skipping file ', $ref->basename, ' with index ', $ref->index);
            next REF;
        }
        if  ($ref->format eq 'PDF') {
            $self->create_thumbnail_from_pdf($ref); 
        } else {
            $self->create_thumbnail_from_image($ref); 
        }    
    }
}


1; # Magic true value required at end of module

__END__
