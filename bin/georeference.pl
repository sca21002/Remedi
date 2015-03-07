#!/usr/bin/env perl
use utf8;
use Path::Tiny;
use FindBin qw($Bin);
use Data::Dumper;
use Modern::Perl;
use Carp;
use Capture::Tiny ':all';
use Getopt::Long;
use Log::Log4perl qw(:easy);

# ABSTRACT: georeference.pl
# PODNAME: georeference.pl

my @header_expected = ( qw(mapX mapY pixelX pixelY enable) );

my $gcp_dir;
my $tiff_src;
my $tiff_dst;

GetOptions (
    "gcp_dir=s"   => \$gcp_dir,
    "tiff_src=s"  => \$tiff_src,
    "tiff_dst=s"  => \$tiff_dst,   
) or die("Error in command line arguments\n");

my $logfile = path($Bin)->parent(1)->child('georeference.log');

### Logdatei initialisieren
Log::Log4perl->easy_init(
    { level   => $DEBUG,
      file    => ">" . $logfile,
    },
    { level   => $TRACE,
      file    => 'STDOUT',
    },
);

$gcp_dir  = path($gcp_dir);
$tiff_src = path($tiff_src);
$tiff_dst = path($tiff_dst);

INFO('Groundcontrolpoint dir: ' . $gcp_dir);
INFO('TIFF source dir:        ' . $tiff_src);
INFO('TIFF destintation dir:  ' . $tiff_dst);

LOGCROAK("Directory of groundcontrolpoints doesn't exist")
    unless $gcp_dir->is_dir;
LOGCROAK("Directory of TIFF source files doesn't exist")
    unless $tiff_src->is_dir;
$tiff_dst->mkpath() unless $tiff_dst->is_dir;

my @gcp_files = path($gcp_dir)->children( qr/\.tif\.points$/ );

INFO(scalar @gcp_files, " groundcontrolpoint files found");

foreach my $gcp_file (@gcp_files) {
    INFO("Working  $gcp_file");
    write_gcps($gcp_file);
}

sub write_gcps {
    my $gcp_file = shift;

    my ($tiff_basename) = $gcp_file->basename =~ qr/(.*)\.points$/; 
    # my ($tiff_filestem) = $tiff_basename =~ qr/(.*)\.[^.]*$/;
    my $tiff_file       = path($tiff_src, $tiff_basename);
    carp("$tiff_file doesn't exist") unless $tiff_file->is_file;
    my $tiff_out     = path($tiff_dst, $tiff_basename);
    #$tiff_file->move($tiff_save) 
    #    or LOGCROAK("move $tiff_file --> $tiff_save failed");
    #INFO("move $tiff_file --> $tiff_save");
    
    #LOGCROAK("$tiff_save doesn't exist") unless  $tiff_save->is_file;


    my $data = $gcp_file->slurp;
    
    my @lines  = split "\n", $data;
    my @header = split ',', shift @lines;
    
    LOGCROAK('Unexpected header') unless @header == @header_expected;
    for (my $i = 0; $i <= $#header; $i++) {
        LOGCROAK('Unexpected header') unless $header[$i] eq $header_expected[$i];
    } 
    
    my (%row, @coords);
    foreach my $line ( @lines ) {
        next if $line =~ /^\s*$/;
        @row{@header} = map { s/^\s+|\s+$//gr }  split ',', $line;
        push @coords, { %row };
    }
    
    my $cmd =  'gdal_translate';
    
    my @options = (
        -of   => 'GTiff',
        -a_srs => 'EPSG:3857', 
    ); 
    
    foreach my $coord (@coords) {
        next unless $coord->{enable} == 1;
        push @options, '-gcp';
        push @options, 
            sprintf("%.6g",   $coord->{pixelX}),
            sprintf("%.6g", - $coord->{pixelY}),
            sprintf("%.6g",   $coord->{mapX}),
            sprintf("%.6g",   $coord->{mapY}),
        ;
    }
    INFO(join ' ', $cmd, @options);
    
    my ($stdout, $stderr, $exit) = tee {
        system($cmd, @options, $tiff_file, $tiff_out);
    };
    INFO($stdout);
    INFO("Error: $stderr") if $stderr;
}

=encoding utf-8

=head1 NAME
 
georeference.pl - Put georeferencing metadata to TIFF files producing GeoTIFF

=head1 SYNOPSIS

georeference.pl --gcp_dir --tiff_src --tiff_dst 


=head1 DESCRIPTION

Put georeferencing metadata to TIFF files producing GeoTIFFs


Reads the text files with groundcontrolpoints (GCP) in gcp_dir, searches for matching 
TIFF files and add the GCP to TIFF header


=head1 AUTHOR

Albert Schröder <albert.schroeder@ur.de>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

