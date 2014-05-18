use utf8;
package Remedi::Document::Thesis::DC;

# ABSTRACT: Class for a METS document for thesis with DC metadata

use Moose;
    extends qw(Remedi::Document);
    with    qw(Remedi::Urn_nbn_de);

use aliased 'Remedi::METS::XML::DC::Creator' => 'DC::Creator';
use aliased 'Remedi::METS::XML::DC::Date' => 'DC::Date';
use aliased 'Remedi::METS::XML::DC::Title' => 'DC::Title';
use aliased 'Remedi::METS::XML::DC::Identifier' => 'DC::Identifier';
use aliased 'Remedi::METS::XML::DC::Publisher' => 'DC::Publisher';
use aliased 'Remedi::METS::XML::DmdSec';
use aliased 'Remedi::METS::XML::Record';
use aliased 'Remedi::METS::XML::DC::Source' => 'DC::Source';
use aliased 'Remedi::METS::XML::DCTERMS::Mediator' => 'DCTERMS::Mediator';
use aliased 'Remedi::METS::XML::MdWrap';
use aliased 'Remedi::METS::XML::XmlData';


use Remedi::Types qw(ArrayRef B3KatID Str NonEmptySimpleStr);
use MooseX::AttributeShortcuts;
use namespace::autoclean;

has 'author'        => ( is => 'ro', isa => NonEmptySimpleStr, required => 1 );
has '+bv_nr'        => ( required => 1 );
has '+shelf_number' => (required => 1);
has 'publisher' =>     (is => 'ro', isa => Str, required => 1);                    

has 'year_of_publication' => (
    is => 'ro',
    isa => NonEmptySimpleStr,
    required => 1
);


sub get_mdWrap {
    my $self = shift;
    
    my $mdWrap = MdWrap->new({MDTYPE=> "DC"});
    my $xmlData = XmlData->new();
    my $record = Record->new({
        xsi => "http://www.w3.org/2001/XMLSchema-instance",
        dc  => "http://purl.org/dc/elements/1.1/",
        dcterms => "http://purl.org/dc/terms/",
    });
    $record->add_title(      DC::Title->new({
        text => $self->title,
    }) );
    $record->add_creator(    DC::Creator->new({
        text => $self->author
    }) );    
    $record->add_date(       DC::Date->new({
        text => $self->year_of_publication
    }) );
    $record->add_mediator(   DCTERMS::Mediator->new({
        text => 'DE-355'
    }) );
    $record->add_identifier( DC::Identifier->new({
        text => $self->bv_nr
    }) );
    $record->add_source(     DC::Source->new({               
            text => $self->shelf_number,
    }) );
    $record->add_publisher(  DC::Publisher->new({               
        text => $self->publisher,
    }) );
    $xmlData->add_record($record);
    $mdWrap->add_xmlData($xmlData);
    return $mdWrap;
}

sub get_dmdSec {
    my $self = shift;
    
    my $dmdSec = DmdSec->new({
        ID => "dmd-dc"
    });
    $dmdSec->add_mdWrap( $self->get_mdWrap);
    return $dmdSec;
}

__PACKAGE__->meta->make_immutable;

1;
