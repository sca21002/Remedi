package Remedi::Urn_nbn_de;

# ABSTRACT: Role for generating URNs in the nbn::de namespace

use Moose::Role;
    requires 'get_niss';

use Remedi::Types qw(Digit ISIL Library_id Library_union_id Niss Str);
use List::Util;
use MooseX::AttributeShortcuts;

sub urn_nbn_de { 'urn:nbn:de:' };

has '_check_digit'   => ( is => 'lazy', isa => Digit );

has 'isil' => ( is => 'ro', isa => ISIL, required => 1 );

has 'library_union_id' => (
    is => 'ro',
    isa      => Library_union_id,
    required => 1
);

has 'library_id' => ( is => 'lazy', isa => Library_id );    
    
has 'niss'     => ( is => 'lazy', isa => Niss );
has '_pre_urn' => ( is => 'lazy', isa => Str  );
has 'urn'      => ( is => 'lazy', isa => Str  );

sub _build__check_digit {
    my $self = shift;
    my $check_digit;
   
    # helper table for calculation of check digits for urn building                                
    my %char_int_map = (
        0  => 1,    1  => 2,    2  => 3,    3  => 4,    4  => 5,
        5  => 6,    6  => 7,    7  => 8,    8  => 9,    9  => 41,
        A  => 18,   B  => 14,   C  => 19,   D  => 15,   E  => 16,
        F  => 21,   G  => 22,   H  => 23,   I  => 24,   J  => 25,
        K  => 42,   L  => 26,   M  => 27,   N  => 13,   O  => 28,
        P  => 29,   Q  => 31,   R  => 12,   S  => 32,   T  => 33,
        U  => 11,   V  => 34,   W  => 35,   X  => 36,   Y  => 37,
        Z  => 38,  '-' => 39,  ':' => 17,
    );
    
    my @chars = split //, $self->_pre_urn;                  # in single chars                                
    my @integers = map { $char_int_map{uc $_} } @chars;    # map  to integers
    my $numerical_sequence = join "", @integers;           # sequence of digits   
    my @digits = split //, $numerical_sequence;            # in single digits
    my @digits_times_pos = map { $digits[$_] * ($_ + 1) } 0..$#digits;
                                                           # digit x position                           
    $check_digit = List::Util::sum @digits_times_pos;
    $check_digit /= $digits[-1];                # divide by last digit
    $check_digit = int($check_digit);           # doesn't round but truncates(!) 
    return $check_digit = substr($check_digit,-1,1)         # return last digit
}

sub _build_library_id {
    my $self = shift;
    
    my ($country, $library_id) = $self->isil =~ /^([A-Z]{2})-(.+)$/;
    return $library_id;             # stricter control is done by type library
}

sub _build__pre_urn {
    my $self = shift;
    
    my $urn = $self->urn_nbn_de
           . $self->library_union_id
           . ':'
           . lc($self->library_id)
           . '-'
           . $self->niss
           ;
}

sub _build_niss { (shift)->get_niss; }

sub _build_urn {
    my $self = shift;
    
    return $self->_pre_urn . $self->_check_digit;
}


1; # Magic true value required at end of module
__END__

