package Remedi::METS::XML::FileGrp;

# ABSTRACT: Class for FileGrp in METS XML

use Moose;
use namespace::autoclean;
use XML::Toolkit;

has 'file_collection' => (
     isa         => 'ArrayRef[Remedi::METS::XML::File]',
     is          => 'ro',     init_arg    => 'files',
     traits      => [qw(XML Array)],
     lazy        => 1,
     auto_deref  => 1,
     default     => sub { [] },
     handles    => { add_file => ['push'] },     description => {
        LocalName => "file",
        Prefix => "",
        node_type => "child",
        Name => "file",
        NamespaceURI => "http://www.loc.gov/METS/",
        sort_order => 0,
     },
);
has 'ID' => (
     isa         => 'Str',
     is          => 'ro',   
     traits      => [ 'XML'],
     description => {
        LocalName => "ID",
        Prefix => "",
        node_type => "attribute",
        Name => "ID",
        NamespaceURI => "",
        sort_order => 1,
     },
);
has 'USE' => (
     isa         => 'Str',
     is          => 'ro',   
     traits      => [ 'XML'],
     description => {
        LocalName => "USE",
        Prefix => "",
        node_type => "attribute",
        Name => "USE",
        NamespaceURI => "",
        sort_order => 2,
     },
);

__PACKAGE__->meta->make_immutable;

1;

__END__
