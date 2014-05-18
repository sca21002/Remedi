use utf8;
package Remedi::ExifTool::Tag;

# ABSTRACT: Class for metadata tags with ExifTool

use Moose;
use namespace::autoclean;

has 'group' => (
    traits => ['Hash'],
    is      => 'ro',
    isa     => 'HashRef[Remedi::ExifTool::Tag::Base]',
    default => sub { {} },
    handles => {
        set_group => 'set',
        get_group => 'get',
        get_groups => 'keys',
        has_group => 'exists',
    }
);

__PACKAGE__->meta->make_immutable;
    
1; # Magic true value required at end of module

