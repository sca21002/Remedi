package Remedi::METS::XML::PREMIS::ObjectIdentifier;

# ABSTRACT: Class for PREMIS::ObjectIdentifier in METS XML

use Moose;
use namespace::autoclean;
use XML::Toolkit;

has 'objectIdentifierType_collection' => (
     isa         => 'ArrayRef[Remedi::METS::XML::PREMIS::ObjectIdentifierType]',
     is          => 'ro',
     init_arg    => 'objectIdentifierTypes',
     traits      => [qw(XML Array)],
     lazy        => 1,
     auto_deref  => 1,
     default     => sub { [] },
     handles    => { add_objectIdentifierType => ['push'] },     description => {
        LocalName => "objectIdentifierType",
        Prefix => "",
        node_type => "child",
        Name => "objectIdentifierType",
        NamespaceURI => "http://www.loc.gov/standards/premis",
        sort_order => 0,
     },
);
has 'objectIdentifierValue_collection' => (
     isa         => 'ArrayRef[Remedi::METS::XML::PREMIS::ObjectIdentifierValue]',
     is          => 'ro',
     init_arg    => 'objectIdentifierValues',
     traits      => [qw(XML Array)],
     lazy        => 1,
     auto_deref  => 1,
     default     => sub { [] },
     handles    => { add_objectIdentifierValue => ['push'] },     description => {
        LocalName => "objectIdentifierValue",
        Prefix => "",
        node_type => "child",
        Name => "objectIdentifierValue",
        NamespaceURI => "http://www.loc.gov/standards/premis",
        sort_order => 1,
     },
);

__PACKAGE__->meta->make_immutable;

1;

__END__
