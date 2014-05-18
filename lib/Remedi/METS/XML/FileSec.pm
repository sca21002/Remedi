package Remedi::METS::XML::FileSec;

# ABSTRACT: Class for FileSec in METS XML

use Moose;
use namespace::autoclean;
use XML::Toolkit;

has 'fileGrp_collection' => (
     isa         => 'ArrayRef[Remedi::METS::XML::FileGrp]',
     is          => 'ro',     init_arg    => 'fileGrps',
     traits      => [qw(XML Array)],
     lazy        => 1,
     auto_deref  => 1,
     default     => sub { [] },
     handles    => { add_fileGrp => ['push'] },     description => {
        LocalName => "fileGrp",
        Prefix => "",
        node_type => "child",
        Name => "fileGrp",
        NamespaceURI => "http://www.loc.gov/METS/",
        sort_order => 0,
     },
);

__PACKAGE__->meta->make_immutable;

1;

__END__
