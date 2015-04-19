use utf8;
package Remedi::ThumbnailFromTIFF;

# ABSTRACT: Role for creating thumbnails from TIFF files

use Moose::Role;

use Remedi::ImageMagickCmds;
use Remedi::Types qw(Dir Path Str);
use MooseX::AttributeShortcuts;
use Path::Tiny qw(path);

use namespace::autoclean;

has 'tiff' => ( is => 'ro', isa => Dir, required => 1, coerce => 1 );

has 'thumbnail' => ( is => 'ro', isa => Path, coerce => 1 );

has '_thumbnail_dir' => ( is => 'lazy', isa => Dir );

has '_name' => ( is => 'ro', isa => Str, default => 'ThumbnailFromTIFF' );


sub _build__thumbnail_dir {
    my $self = shift;

    my $thumbnail_dir = 
        $self->thumbnail || $self->tiff_dir->parent->child('thumbnail');

    # if the dir doesn't exist, a new one is created 
    # if a file with the same name exists, Path::Tiny throws an error
    $thumbnail_dir->mkpath() unless $thumbnail_dir->is_dir;
    return $thumbnail_dir;
}


sub create_thumbnail {
    my $self = shift;

    my $log = $self->log;
    $log->info('Starting create_thumbnail');
    $log->debug('TIFF dir ', $self->tiff);
    $log->debug('Thumbnail dir ', $self->_thumbnail_dir);

    # collect TIFF files
    my @tiff_files = $self->tiff->children(qr/\.tif$/);
    
    foreach my $tif_file (@tiff_files) {
        # file stem 
        my ($thumbnail_file) = $tif_file->basename =~ /(.*)\.tif$/;
        # thumbnail path
        $thumbnail_file = path(
            $self->_thumbnail_dir, $thumbnail_file . '.gif'
        );
        # convert TIFF into  
        Remedi::ImageMagickCmds::create_thumbnail(
            $tif_file,          # source file
            'GIF',              # thumbnail format
            $thumbnail_file,    # thumbnail path
            200,                # thumbnail height
        );
    }
}


1; # Magic true value required at end of module

__END__

