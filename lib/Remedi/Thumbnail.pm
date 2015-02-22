use utf8;
package Remedi::Thumbnail;

# ABSTRACT: Role for creating thumbnails from PDF reference files

use Moose::Role;
use Remedi::PDF::CAM::PDF;
use Path::Tiny;

use Remedi::Types qw( Str );
use Try::Tiny;


has '_name' => ( is => 'ro', isa => Str, default => 'Thumbnail' );

use namespace::autoclean;

sub create_thumbnail {
    my $self = shift;

    my $log = $self->log;
    $log->info('Starting create_thumbnail');
    $self->reference_files;
    $log->info(scalar @{$self->reference_files} . " reference files found.");
    $log->info("Thumbs dir: " . $self->_thumbnail_dir);
    REF: foreach my $ref (@{$self->reference_files}) {
        # $log->info($ref->basename . '(' . $ref->format . ')' );
        my $pdf = Remedi::PDF::CAM::PDF->new( 
           file => $ref->file
        );
        my $error;
        try {
            $pdf->size;
        }    
        catch {
            $log->warn("Error with PDF: $_");
            $error = 1;
        };    
        next if $error;
        # $log->info($pdf->file . " - " . $pdf->size);
        my $path = path($self->_thumbnail_dir, $ref->filestem . '.gif');
        # $log->info($path); 
        $pdf->create_thumbnail($path);
    }

}


1; # Magic true value required at end of module

__END__
