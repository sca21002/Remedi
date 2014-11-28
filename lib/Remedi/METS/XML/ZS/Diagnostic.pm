package Remedi::METS::XML::ZS::Diagnostic;

# ABSTRACT: Class for ZS::Message in METS XML

use Moose;
use namespace::autoclean;
use XML::Toolkit;

has 'details_collection' => (
     isa         => 'ArrayRef[Remedi::METS::XML::ZS::Details]',
     is          => 'ro',     init_arg    => 'detailss',
     traits      => [qw(XML Array)],
     lazy        => 1,
     auto_deref  => 1,
     default     => sub { [] },
     handles    => { add_details => ['push'] },     description => {
        LocalName => "details",
        Prefix => "",
        node_type => "child",
        Name => "details",
        NamespaceURI => "http://www.loc.gov/zing/srw/diagnostic/",
        sort_order => 0,
     },
);
has 'message_collection' => (
     isa         => 'ArrayRef[Remedi::METS::XML::ZS::Message]',
     is          => 'ro',     init_arg    => 'messages',
     traits      => [qw(XML Array)],
     lazy        => 1,
     auto_deref  => 1,
     default     => sub { [] },
     handles    => { add_message => ['push'] },     description => {
        LocalName => "message",
        Prefix => "",
        node_type => "child",
        Name => "message",
        NamespaceURI => "http://www.loc.gov/zing/srw/diagnostic/",
        sort_order => 1,
     },
);
has 'uri_collection' => (
     isa         => 'ArrayRef[Remedi::METS::XML::ZS::Uri]',
     is          => 'ro',     init_arg    => 'uris',
     traits      => [qw(XML Array)],
     lazy        => 1,
     auto_deref  => 1,
     default     => sub { [] },
     handles    => { add_uri => ['push'] },     description => {
        LocalName => "uri",
        Prefix => "",
        node_type => "child",
        Name => "uri",
        NamespaceURI => "http://www.loc.gov/zing/srw/diagnostic/",
        sort_order => 2,
     },
);

__PACKAGE__->meta->make_immutable;

1;

__END__
