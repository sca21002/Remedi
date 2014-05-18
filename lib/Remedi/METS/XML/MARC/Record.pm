package Remedi::METS::XML::MARC::Record;

# ABSTRACT: Class for MARC::Record in METS XML

use Moose;
use namespace::autoclean;
use XML::Toolkit;

has 'controlfield_collection' => (
     isa         => 'ArrayRef[Remedi::METS::XML::MARC::Controlfield]',
     is          => 'ro',
     init_arg    => 'controlfields',
     traits      => [qw(XML Array)],
     lazy        => 1,
     auto_deref  => 1,
     default     => sub { [] },
     handles    => {
        add_controlfield   => ['push'],
        grep_controlfields => 'grep',
     },
     description => {
        LocalName => "controlfield",
        Prefix => "",
        node_type => "child",
        Name => "controlfield",
        NamespaceURI => "http://www.loc.gov/MARC21/slim",
        sort_order => 2,
     },
);
has 'datafield_collection' => (
     isa         => 'ArrayRef[Remedi::METS::XML::MARC::Datafield]',
     is          => 'ro',
     init_arg    => 'datafields',
     traits      => [qw(XML Array)],
     lazy        => 1,
     auto_deref  => 1,
     default     => sub { [] },
     handles    => {
        add_datafield         => ['push'],
        first_index_datafield => 'first_index',
        get_datafield         => 'get',
        grep_datafields       => 'grep',
        delete_datafield      => 'delete',
     },
     description => {
        LocalName => "datafield",
        Prefix => "",
        node_type => "child",
        Name => "datafield",
        NamespaceURI => "http://www.loc.gov/MARC21/slim",
        sort_order => 3,
     },
);
has 'leader_collection' => (
     isa         => 'ArrayRef[Remedi::METS::XML::MARC::Leader]',
     is          => 'ro',
     init_arg    => 'leaders',
     traits      => [qw(XML Array)],
     lazy        => 1,
     auto_deref  => 1,
     default     => sub { [] },
     handles    => {
        add_leader => ['push'] },
     description => {
        LocalName => "leader",
        Prefix => "",
        node_type => "child",
        Name => "leader",
        NamespaceURI => "http://www.loc.gov/MARC21/slim",
        sort_order => 1,
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
        sort_order => 0,
     },
);

__PACKAGE__->meta->make_immutable;

1;

__END__
