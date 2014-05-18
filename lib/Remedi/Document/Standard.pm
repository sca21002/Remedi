use utf8;
package Remedi::Document::Standard;

# ABSTRACT: Class for a basic METS document

use Moose;
    extends qw(Remedi::Document);
    with    qw(Remedi::Urn_nbn_de);
    
use aliased 'Remedi::METS::XML::DmdSec';
use aliased 'Remedi::METS::XML::MARC::Record';
use aliased 'Remedi::METS::XML::MARC::Controlfield';
use aliased 'Remedi::METS::XML::MARC::Datafield';
use aliased 'Remedi::METS::XML::MARC::Leader';
use aliased 'Remedi::METS::XML::MARC::Subfield';
use aliased 'Remedi::METS::XML::MdWrap';
use aliased 'Remedi::METS::XML::XmlData';

use Remedi::Types qw(ArrayRef B3KatID Lang);

use MooseX::AttributeShortcuts;
use namespace::autoclean;

has 'lang' => (is => 'ro', isa => Lang, required => 1);

has '+shelf_number' => ( predicate => 1 );

sub get_mdWrap {
    my $self = shift;
    
    my $marc_record = Record->new({
        xmlns => 'http://www.loc.gov/MARC21/slim',   
        leaders => [
            Leader->new({ text => '00000nam#a2200000zu#4500' }),
        ],
        controlfields => [
            Controlfield->new({
                tag  => '001',
                text => $self->bv_nr,
            }),
            Controlfield->new({
                tag  => '008',
                text => $self->create_date->strftime('%y%m%d')
                        . '|^^^^^^^^|||^^^#s####|||#|||'
                        . $self->lang. '##',
            }),
        ],
        datafields => [
            Datafield->new({
                tag => '852',
                subfields => [
                    Subfield->new({
                        code => 'a',
                        text => $self->isil,
                    }),
                    $self->get_shelf_number,
                ],
            }),
        ],
    });

    my $mdWrap = MdWrap->new({
        MDTYPE => 'MARC',
        xmlDatas => [
            XmlData->new({
                marc_records => [ $marc_record ],
            }),
        ],
    });
    return $mdWrap;
}

sub get_dmdSec {
    my $self = shift;
    
    my $dmdSec = DmdSec->new({
        ID => "dmd-marc"
    });
    $dmdSec->add_mdWrap($self->get_mdWrap);
    return $dmdSec;
}

sub get_shelf_number {
    my $self = shift;
    
    return unless $self->has_shelf_number;
    return Subfield->new({
        code => 'j', text => $self->shelf_number,
    });  
}


__PACKAGE__->meta->make_immutable;

1;