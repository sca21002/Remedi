package Remedi::Imagefile::Reference;

# ABSTRACT: Image file of type reference

use Moose;
    extends qw(Remedi::Imagefile);
    with 'Remedi::Urn_nbn_de'; 

use Remedi::Types qw(Usetype);
use namespace::autoclean;

has 'usetype' => (
    is => 'ro',
    isa => Usetype,
    default => 'reference',
);

sub get_niss {
    my $self = shift;
    my $niss = lc($self->filestem);
    $niss =~ s/_/-/g;
    $niss .= '-';
    return $niss;
}

__PACKAGE__->meta->make_immutable;

1;
