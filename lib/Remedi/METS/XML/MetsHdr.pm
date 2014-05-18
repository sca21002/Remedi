package Remedi::METS::XML::MetsHdr;

# ABSTRACT: Class for MetsHdr in METS XML

use Moose;
use namespace::autoclean;
use XML::Toolkit;

has 'agent_collection' => (
     isa         => 'ArrayRef[Remedi::METS::XML::Agent]',
     is          => 'ro',     init_arg    => 'agents',
     traits      => [qw(XML Array)],
     lazy        => 1,
     auto_deref  => 1,
     default     => sub { [] },
     handles    => { add_agent => ['push'] },
     description => {
        LocalName => "agent",
        Prefix => "",
        node_type => "child",
        Name => "agent",
        NamespaceURI => "http://www.loc.gov/METS/",
        sort_order => 0,
     },
);
has 'CREATEDATE' => (
     isa         => 'Str',
     is          => 'ro',   
     traits      => [ 'XML'],
     description => {
        LocalName => "CREATEDATE",
        Prefix => "",
        node_type => "attribute",
        Name => "CREATEDATE",
        NamespaceURI => "",
        sort_order => 1,
     },
);
has 'RECORDSTATUS' => (
     isa         => 'Str',
     is          => 'ro',   
     traits      => [ 'XML'],
     default     => 'new',
     description => {
        LocalName => "RECORDSTATUS",
        Prefix => "",
        node_type => "attribute",
        Name => "RECORDSTATUS",
        NamespaceURI => "",
        sort_order => 2,
     },
);

__PACKAGE__->meta->make_immutable;

1;

__END__
