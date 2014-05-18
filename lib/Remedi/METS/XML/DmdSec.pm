package Remedi::METS::XML::DmdSec;

# ABSTRACT: Class for DmdSec in METS XML

use Moose;
use namespace::autoclean;
use XML::Toolkit;

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
        sort_order => 0,
     },
);
has 'mdWrap_collection' => (
     isa         => 'ArrayRef[Remedi::METS::XML::MdWrap]',
     is          => 'ro',     init_arg    => 'mdWraps',
     traits      => [qw(XML Array)],
     lazy        => 1,
     auto_deref  => 1,
     default     => sub { [] },
     handles    => { add_mdWrap => ['push'] },     description => {
        LocalName => "mdWrap",
        Prefix => "",
        node_type => "child",
        Name => "mdWrap",
        NamespaceURI => "http://www.loc.gov/METS/",
        sort_order => 1,
     },
);

__PACKAGE__->meta->make_immutable;

1;

__END__
