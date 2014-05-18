use utf8;
package Remedi::Types;

# ABSTRACT: Types libraries used in Remedi

use strict; 
use warnings;

use parent 'MooseX::Types::Combine'; 
 
__PACKAGE__->provide_types_from( qw(
    MooseX::Types::Common::Numeric                            
    MooseX::Types::Common::String                            
    MooseX::Types::Perl 
    MooseX::Types::Moose
    MooseX::Types::URI
    Remedi::Types::Remedi
));

1;
