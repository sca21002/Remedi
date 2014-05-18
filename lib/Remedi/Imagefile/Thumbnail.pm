package Remedi::Imagefile::Thumbnail;

# ABSTRACT: Image file of type thumbnail

use Moose;
    extends qw(Remedi::Imagefile);

use Remedi::Types qw(Usetype);
use namespace::autoclean;
    
has 'usetype' => (
    is => 'ro',
    isa => Usetype,
    default => 'thumbnail',
);


__PACKAGE__->meta->make_immutable;
    
1;
