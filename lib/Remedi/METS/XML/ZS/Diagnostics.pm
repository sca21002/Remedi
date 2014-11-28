package Remedi::METS::XML::ZS::Diagnostics;

# ABSTRACT: Class for ZS::Diagnostics in METS XML

use Moose;
use namespace::autoclean;
use XML::Toolkit;

has 'diagnostic_collection' => (
     isa         => 'ArrayRef[Remedi::METS::XML::ZS::Diagnostic]',
     is          => 'ro',     init_arg    => 'diagnostics',
     traits      => [qw(XML Array)],
     lazy        => 1,
     auto_deref  => 1,
     default     => sub { [] },
     handles    => { add_diagnostic => ['push'] },     description => {
        LocalName => "diagnostic",
        Prefix => "",
        node_type => "child",
        Name => "diagnostic",
        NamespaceURI => "http://www.loc.gov/zing/srw/diagnostic/",
        sort_order => 0,
     },
);
has 'xmlns' => (
     isa         => 'Str',
     is          => 'ro',   
     traits      => [ 'XML'],
     description => {
        LocalName => "xmlns",
        Prefix => "",
        node_type => "attribute",
        Name => "xmlns",
        NamespaceURI => "",
        sort_order => 1,
     },
);

__PACKAGE__->meta->make_immutable;

1;

__END__
