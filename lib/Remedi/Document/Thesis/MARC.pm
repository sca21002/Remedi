use utf8;
package Remedi::Document::Thesis::MARC;

# ABSTRACT: Class for a METS document for thesis with DC metadata

use Moose;
    extends qw(Remedi::Document);
    with    qw(
        Remedi::Urn_nbn_de
        MooseX::Log::Log4perl
    );

    
use Remedi::BVB::SRU;
use aliased 'Remedi::METS::XML::DmdSec';
use aliased 'Remedi::METS::XML::MARC::Controlfield' => 'MARC::Controlfield';
use aliased 'Remedi::METS::XML::MARC::Datafield' => 'MARC::Datafield';
use aliased 'Remedi::METS::XML::MARC::Subfield' => 'MARC::Subfield';
use aliased 'Remedi::METS::XML::MARC::Record' => 'MARC::Record';
use aliased 'Remedi::METS::XML::MdWrap';
use aliased 'Remedi::METS::XML::XmlData';
use Remedi::Types qw(ArrayRef NonEmptySimpleStr Str);
use MooseX::AttributeShortcuts;
use Try::Tiny;
use XML::Toolkit::App;
use namespace::autoclean;

has '+bv_nr'               => ( required => 1 );
has '+isil'                => ( required => 1 );
has 'publisher'            => ( is => 'ro', isa => Str, required => 1); 
has '+shelf_number'        => ( required => 1 );

has 'year_of_publication' => (
    is => 'ro',
    isa => NonEmptySimpleStr,
    required => 1
);


sub get_mdWrap {
    my $self = shift;
    
    my $log = $self->log;
    my $mdWrap = MdWrap->new({MDTYPE => 'MARC'});
    my $xmlData = XmlData->new();
    
    my $marc_xml;
    
    try {
        $marc_xml = Remedi::BVB::SRU->new()->get_marc_xml($self->bv_nr);
    }
    catch {
        $log->logcroak("Couldn't fetch MARC-XML: $_");
    };
    
    $self->log->info('MARC-XML fetched for ' . $self->bv_nr);

    my $loader = XML::Toolkit::App->new({
        namespace_map => {
            'http://www.loc.gov/zing/srw/'   => 'Remedi::METS::XML::ZS',
            'http://www.loc.gov/MARC21/slim' => 'Remedi::METS::XML::MARC',
        },
    })->loader;
    $loader->parse_string($marc_xml);
    my $root = $loader->root_object;
    my $marc_record = $root
        ->records_collection->[0]
        ->record_collection->[0]
        ->recordData_collection->[0]                
        ->record_collection->[0];
    
    my (@cfs) = $marc_record->grep_controlfields(sub{$_->tag eq '001'});
    
    foreach my $cf (@cfs) {
    my $bv_nr = $cf->text;
        $bv_nr =~ s/^(BV\d{9})$/B3Kat $1/
            or $log->logcroak("Couldn't prefix BV-Nr '$bv_nr'");
        $cf->text($bv_nr);
    }
    
    my $index = $marc_record->first_index_datafield( sub{$_->tag eq '856'} );
    if ($index >= 0) {                                     # -1 = not found
        $log->info("ELECTRONIC LOCATION AND ACCESS found (index: $index)");
        my $datafield = $marc_record->get_datafield($index);
        my (@sfs) = $datafield->grep_subfields( sub{$_->code eq '3'} );
        if (@sfs) {
            $log->warn($sfs[0]->text . ' will be deleted')
        }
        $marc_record->delete_datafield($index)
            or $log->logcroak("Couldn't delete datafield #$index");
    }
    
    $marc_record->add_datafield(
        MARC::Datafield->new(
            tag => '852',
            subfields => [
                MARC::Subfield->new({
                    code => 'a', text => $self->isil,
                }),
                MARC::Subfield->new({
                    code => 'j', text => $self->shelf_number,
                }),                          
            ]
        ),
    );
    
    $xmlData->add_record($marc_record);
    $mdWrap->add_xmlData($xmlData);
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

__PACKAGE__->meta->make_immutable;

1;
