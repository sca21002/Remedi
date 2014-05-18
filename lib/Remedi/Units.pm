package Remedi::Units;

# ABSTRACT: Units used in Remedi

use strict;
use warnings;

use parent 'Exporter';

# constants
sub pt_pro_mm { 72 / 25.4 }  # Point = unit of measure in Acrobat
                                # 1 pt = 1/72 inch, 1 inch = 25.4 mm
sub pt_pro_inch { 72 }

our @EXPORT = qw(pt_pro_mm pt_pro_inch);


1; # Magic true value required at end of module
__END__