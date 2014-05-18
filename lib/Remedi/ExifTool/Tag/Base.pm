use utf8;
package Remedi::ExifTool::Tag::Base;

# ABSTRACT: Base class for metadata tags with ExifTool

use Moose;
use namespace::autoclean;

__PACKAGE__->meta->make_immutable;

1; # Magic true value required at end of module

