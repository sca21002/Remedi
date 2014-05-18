package Remedi::Imagefile::Ingest;

# ABSTRACT: File prepared to be ingested

use Moose;
    extends qw(Remedi::Imagefile);
    
use Remedi::Types;
use namespace::autoclean;

__PACKAGE__->meta->make_immutable;

1;
