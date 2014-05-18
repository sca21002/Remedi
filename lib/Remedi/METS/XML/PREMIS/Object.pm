package Remedi::METS::XML::PREMIS::Object;

# ABSTRACT: Class for PREMIS::Object in METS XML

use Moose;
use namespace::autoclean;
use XML::Toolkit;

has 'objectIdentifier_collection' => (
     isa         => 'ArrayRef[Remedi::METS::XML::PREMIS::ObjectIdentifier]',
     is          => 'ro',
     init_arg    => 'objectIdentifiers',
     traits      => [qw(XML Array)],
     lazy        => 1,
     auto_deref  => 1,
     default     => sub { [] },
     handles    => { add_objectIdentifier => ['push'] },     description => {
        LocalName => "objectIdentifier",
        Prefix => "",
        node_type => "child",
        Name => "objectIdentifier",
        NamespaceURI => "http://www.loc.gov/standards/premis",
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
