use utf8;
package Remedi::PDF::Pagelabel;

# ABSTRACT: Class for Pagelabels in PDF::API2 

use Moose;
use Moose::Util::TypeConstraints qw(enum);
use MooseX::AttributeShortcuts;
use Remedi::Types qw(Num Str);
use namespace::autoclean;

use MooseX::Types -declare => [ qw(LabelPrefix LabelStart LabelStyle PageNo) ];

subtype LabelStyle,
    as enum([qw(alpha Roman Alpha roman decimal), '']),
    message { "'$_' is not a known label style."};
    
subtype LabelStart,
    as Num,
    where { $_ >= 1 },                  # cf. PDF Reference, sec 8.3.1
    message { "'$_' is not an allowed number for label start." };
    
subtype LabelPrefix,
    as Str,
    where { /.*/ },
    message { "'$_' is not an allowed label prefix." };
    
subtype PageNo,
    as Num,
    where { $_ >= 0 },
    message { "'$_' is not an allowed page number." };

has 'style'   => ( is => 'lazy', isa => LabelStyle );

has 'start'   => ( is => 'lazy', isa => LabelStart );

has 'prefix'  => ( is => 'lazy', isa => LabelPrefix );

has 'page_no' => ( is => 'ro', isa => PageNo, required => 1 );

sub _build_style { '' };

sub _build_start { 1 };

sub _build_prefix { '' };

sub keys { qw(S St P) };

sub key_map {
    S   => 'style',
    St  => 'start',
    P   => 'prefix',
};

sub style_map { 
    A  => 'Alpha',
    a  => 'alpha',
    D  => 'decimal',
    r  => 'roman',
    R  => 'Roman',
};
    
__PACKAGE__->meta->make_immutable;
1;

#PDF Reference
#third edition
#Adobe Portable Document Format
#Version 1.4
