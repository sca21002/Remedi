package Remedi::METS::XML::AmdSec;

# ABSTRACT: Class for AmdSec in METS XML

use Moose;
use namespace::autoclean;
use XML::Toolkit;

has 'sourceMD_collection' => (
     isa         => 'ArrayRef[Remedi::METS::XML::SourceMD]',
     is          => 'ro',
     init_arg    => 'sourceMDs',
     traits      => [qw(XML Array)],
     lazy        => 1,
     auto_deref  => 1,
     default     => sub { [] },
     handles    => { add_sourceMD => ['push'] },     description => {
        LocalName => "sourceMD",
        Prefix => "",
        node_type => "child",
        Name => "sourceMD",
        NamespaceURI => "http://www.loc.gov/METS/",
        sort_order => 0,
     },
);

__PACKAGE__->meta->make_immutable;

1;

__END__
