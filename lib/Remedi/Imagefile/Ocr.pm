package Remedi::Imagefile::Ocr;

# ABSTRACT: XML file with OCR results

use Moose;
    extends qw(Remedi::RemediFile);
use Remedi::Types qw(Usetype);
use namespace::autoclean;
    
has 'usetype' => (
    is => 'ro',
    isa => Usetype,
    default => 'ocr',
);

__PACKAGE__->meta->make_immutable;
   
1;
