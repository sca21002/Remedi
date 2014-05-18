package Remedi::METS::XML::XmlData;

# ABSTRACT: Class for XmlData in METS XML

use Moose;
use namespace::autoclean;
use XML::Toolkit;

has 'object_collection' => (
     isa         => 'ArrayRef[Remedi::METS::XML::PREMIS::Object]',
     is          => 'ro',
     init_arg    => 'objects',
     traits      => [qw(XML Array)],
     lazy        => 1,
     auto_deref  => 1,
     default     => sub { [] },
     handles    => { add_object => ['push'] },     description => {
        LocalName => "object",
        Prefix => "",
        node_type => "child",
        Name => "object",
        NamespaceURI => "http://www.loc.gov/standards/premis",
        sort_order => 0,
     },
);
has 'record_marc_collection' => (
     isa         => 'ArrayRef[Remedi::METS::XML::MARC::Record]',
     is          => 'ro',
     init_arg    => 'marc_records',
     traits      => [qw(XML Array)],
     lazy        => 1,
     auto_deref  => 1,
     default     => sub { [] },
     handles    => { add_record_marc => ['push'] },
     description => {
        LocalName => "record",
        Prefix => "",
        node_type => "child",
        Name => "record",
        NamespaceURI => "http://www.loc.gov/MARC21/slim",
        sort_order => 2,
     },
);

has 'record_dc_collection' => (
     isa         => 'ArrayRef[Remedi::METS::XML::Record]',
     is          => 'ro',
     init_arg    => 'dc_records',
     traits      => [qw(XML Array)],
     lazy        => 1,
     auto_deref  => 1,
     default     => sub { [] },
     handles    => { add_record_dc => ['push'] },
     description => {
        LocalName => "record",
        Prefix => "",
        node_type => "child",
        Name => "record",
        NamespaceURI => "http://www.loc.gov/METS/",
        sort_order => 1,
     },
);

sub add_record {
    my $self   = shift;
    my $record = shift;
    
    if (ref $record eq 'Remedi::METS::XML::MARC::Record') {    
        $self->add_record_marc($record, @_);
    } else {
        $self->add_record_dc(  $record, @_);    
    }
}

__PACKAGE__->meta->make_immutable;

1;

__END__
