use utf8;
package Remedi::JPEG2000;

# ABSTRACT: Class for a image file in JPEG 2000 format


use Moose;
    with qw(
        Remedi
        MooseX::SimpleConfig
        MooseX::Getopt
        MooseX::Log::Log4perl
    );
use namespace::autoclean;
use File::Path;
use File::Copy;
use Modern::Perl;
use MooseX::AttributeShortcuts;
use Path::Tiny qw(path);
use Remedi::Types qw(ArrayRef Dir LWPUserAgent PositiveNum Str);
use autodie;
use LWP::UserAgent;
use Data::Dumper;
use namespace::autoclean;

has 'jpeg2000_input_dir' => ( is => 'lazy', isa => Dir );

has 'jpeg2000_output_dir' => ( is => 'lazy', isa => Dir);

has 'jpeg2000_url' => (
    is => 'ro',
    isa => Str,
    default => 'http://digipool.bib-bvb.de/bvb/anwender/Grafikverarbeitung/tif2jpeg2000.pl' 
               .'?user=SCHROEDER',
);

has '_name'          => ( is => 'ro', isa => Str, default => 'JPEG2000');

has 'source_files' => ( is => 'lazy', isa => ArrayRef['Remedi::Imagefile'] );

has 'user_agent' => ( is => 'lazy', isa => LWPUserAgent );

has 'timeout' => (is => 'ro', isa => PositiveNum, default => 540);       

sub _build_jpeg2000_input_dir {
    path(
        '/rzblx8_DATA1/digitalisierung/digitool/exchange/TIFF_to_J2K/SCHROEDER/'
    );
}

sub _build_jpeg2000_output_dir { shift->jpeg2000_input_dir->child('fertig') }

sub _build_source_files {
    [ grep { $_->format eq 'TIFF' } @{ (shift)->reference_files } ];
}

sub _build_user_agent {
    my $self = shift;    
    
    LWP::UserAgent->new(timeout => $self->timeout);
}

sub BUILD {
    my $self = shift;
    
    $self->init_logging(@_);
}

sub convert {
    my $self = shift;

    foreach my $source_file (@{$self->source_files}) {
        $self->log->info($source_file->basename);
        my $dest_path = path($self->jpeg2000_input_dir, $source_file->basename);
        copy( $source_file->stringify, $dest_path->stringify )
            or $self->log->logdie(
                "Copy failed for $source_file --> $dest_path: $!"
            );
    }
    my $response = $self->user_agent->get($self->jpeg2000_url);
 
    if ($response->is_success) {
        $self->log->info($response->decoded_content);  # or whatever
    }
    else {
        $self->log->logdie($response->status_line);
    }
}


sub fetch {
    my $self = shift;
    
    foreach my $source_file (@{$self->source_files}) {
        $self->log->info($source_file->filestem . '.jp2');
        my $jp2_file = path(
                $self->jpeg2000_output_dir, $source_file->filestem . '.jp2'
        );
        move( $jp2_file->stringify, $self->_reference_dir->stringify )
            or $self->log->logdie( "Move failed for " . $jp2_file . " --> "
                . $self->_reference_dir->stringify . ": $!"
            );
        (my $cnt = unlink $source_file->stringify) 
            ? $self->log->info($source_file->stringify . " deleted")    
            : $self->log->die("Couldn't delete ". $source_file->stringify ."!");    
    }
    return 1;
}

__PACKAGE__->meta->make_immutable;
 
1;
