use utf8;
package Remedi::Document;

# ABSTRACT: Base class for a METS XML document

use Moose;
    with qw(MooseX::Log::Log4perl);
    
use MooseX::AttributeShortcuts;
use Remedi::Types qw(
    ArrayRefOfRemediFile ArrayRefOfUsetype ArrayRef Bool B3KatID DateTime ISIL
    Library_union_id NonEmptyDoubleStr NonEmptySimpleStr Path RemediFile Str 
    URN_level
);
use DateTime;
use Data::Dumper;
use namespace::autoclean;

use aliased 'Remedi::METS::XML::Agent';
use aliased 'Remedi::METS::XML::AmdSec';
use aliased 'Remedi::METS::XML::Div';
use aliased 'Remedi::METS::XML::File';
use aliased 'Remedi::METS::XML::FileGrp';
use aliased 'Remedi::METS::XML::Fptr';
use aliased 'Remedi::METS::XML::FLocat';
use aliased 'Remedi::METS::XML::FileSec';
use aliased 'Remedi::METS::XML::MdWrap';
use aliased 'Remedi::METS::XML::Mets';
use aliased 'Remedi::METS::XML::MetsHdr';
use aliased 'Remedi::METS::XML::Name';
use aliased 'Remedi::METS::XML::Note';
use aliased 'Remedi::METS::XML::PREMIS::Object' => 'PREMIS::Object';
use aliased 'Remedi::METS::XML::PREMIS::ObjectIdentifier'
                => 'PREMIS::ObjectIdentifier';
use aliased 'Remedi::METS::XML::PREMIS::ObjectIdentifierType'
                => 'PREMIS::ObjectIdentifierType';
use aliased 'Remedi::METS::XML::PREMIS::ObjectIdentifierValue'
                => 'PREMIS::ObjectIdentifierValue';
use aliased 'Remedi::METS::XML::SourceMD';
use aliased 'Remedi::METS::XML::StructMap';
use aliased 'Remedi::METS::XML::XmlData';

has 'archive_files'   => (
    is => 'ro', isa => ArrayRefOfRemediFile, predicate => 1 );

has 'bv_nr'            => ( is => 'rw', isa => B3KatID, required => 1 );
has 'create_date'      => ( is => 'lazy', isa => DateTime );
has 'isil'             => ( is => 'ro', isa => ISIL, required => 1 );
has 'job_file'         => ( is => 'ro', isa =>  RemediFile, predicate => 1);
has 'library_union_id' => ( is => 'ro', isa => Library_union_id, required => 1);
has 'mets_label'       => ( is => 'ro', isa => Str, required => 1 );
has 'ocr_files' => ( is => 'ro', isa => ArrayRefOfRemediFile, predicate => 1);
has 'order_id'  => ( is => 'ro', isa => Str, required => 1);
has 'reference_files' => (
    is => 'ro', isa => ArrayRefOfRemediFile, predicate => 1,
);
has 'sequence' => ( is => 'ro', isa => ArrayRef[Str], predicate => 1 );
has 'shelf_number'  => ( is => 'ro', isa => Str );
has 'is_thesis_workflow'  => ( is => 'ro', isa => Bool, default => 0 );

has 'title' =>  ( is => 'ro', isa => NonEmptyDoubleStr, required => 1 );

has 'thumbnail_files' => (
    is => 'ro', isa => ArrayRefOfRemediFile, predicate => 'has_thumbnail_files',
);

has 'urn_level' => ( is => 'ro', isa => URN_level, default => 'single_page' );

has 'usetypes' => ( is => 'ro', isa => ArrayRefOfUsetype, required => 1 );

sub _build_create_date {
    my $self = shift;
    
    my $create_date = DateTime->now( locale => 'de_DE' );
    $create_date->set_time_zone('Europe/Berlin');
    return $create_date;
}


sub get_mets {
    my $self = shift;
    
    my $mets =
    Mets->new({
        LABEL => $self->mets_label,
        OBJID => $self->order_id,
    });
    my $metshdr = MetsHdr->new({
        CREATEDATE     => $self->create_date->strftime('%FT%T'),
    });
    my $agent_creator = Agent->new({
        OTHERTYPE => "Software",
        ROLE => "CREATOR",
        TYPE => "OTHER",                                 
    });
    $agent_creator->add_name(Name->new({
        text => "Remedi ($Remedi::VERSION)(c) "
                . 'Universitätsbibliothek Regensburg/'
                . 'Bibliotheksverbund Bayern Verbundzentrale',
    }));
    my $agent_editor = Agent->new({
        ROLE => "EDITOR",
        TYPE => "INDIVIDUAL",                                           
    });
    $agent_editor->add_name(Name->new({
        text => $self->order_id
    }));
    $agent_editor->add_note(Note->new());
    $metshdr->add_agent($agent_creator, $agent_editor);
    $mets->add_metsHdr($metshdr);
    $mets->add_dmdSec($self->get_dmdSec);
    
    if ($self->urn_level ne 'no_urn' ) {     # urn_level = object or single_page
        $mets->add_amdSec( $self->get_amdSec(
            $self->order_id . '_urn',
            $self->urn,
        ) );                
    }
    
    if ($self->urn_level eq 'single_page'  and $self->has_reference_files) {
        foreach my $reference_file ( @{$self->reference_files} ) {
            $mets->add_amdSec( $self->get_amdSec(
                $reference_file->filestem . '_urn',
                $reference_file->urn,
            ) );        
        }
    }
    
    my $fileSec = FileSec->new();
    
    my $filegroup_cnt++;
    my $structmap_files;
    my @usetypes = @{$self->usetypes};
    foreach my $usetype ( @usetypes ) {
        my $filegrp = FileGrp->new({
            ID  => 'Filegrp-' . $filegroup_cnt++,                                           
            USE => $usetype,
        });
        my $usetype_files = $usetype . '_files';
        my $predicate = 'has_' . $usetype_files;
        $self->log->logcroak("No $usetype_files")
            unless $self->$predicate;
        foreach my $usetype_file ( @{ $self->$usetype_files } ) {
            my $init_args = {
                CHECKSUM => $usetype_file->md5_checksum,
                CHECKSUMTYPE => "MD5",
                GROUPID      => $usetype_file->index,
                ID           => $usetype_file->id,
                SEQ          => $usetype_file->index,
                SIZE         => $usetype_file->size,
            };
            $init_args->{DMDID} = "dmd-" . $self->order_id
                if $usetype_file->index == 0 and $usetype eq 'reference';
            $init_args->{ADMID} = $usetype_file->filestem . '_urn'
               if $self->urn_level eq 'single_page' and $usetype eq 'reference';
            my $file = File->new($init_args);
            my $flocat = FLocat->new({
                LOCTYPE => "URL",
                href => "file://streams/" . $usetype_file->basename
            });
            $file->add_FLocat($flocat);
            $filegrp->add_file($file);
            $structmap_files->[$usetype_file->index]{order} = $usetype_file->index;
            $structmap_files->[$usetype_file->index]{$usetype} = $usetype_file;
        }        
        $fileSec->add_fileGrp($filegrp);
    }
   
    $self->has_job_file ? $self->log->info('job file') : $self->log->info('kein job file');

    if ($self->has_job_file) {
        my $filegrp = FileGrp->new({
            ID  => 'Filegrp-' . $filegroup_cnt++,                                           
            USE => 'workflow',
        });
        my $job_file = $self->job_file;
        my $init_args = {
            CHECKSUM     => $job_file->md5_checksum,
            CHECKSUMTYPE => "MD5",
            GROUPID      => $job_file->index,
            ID           => $job_file->id,
            SEQ          => $job_file->index,
            SIZE         => $job_file->size,
        };
        my $file = File->new($init_args);
        my $flocat = FLocat->new({
            LOCTYPE => "URL",
            href => "file://streams/" . $job_file->basename
        });
        $file->add_FLocat($flocat);
        $filegrp->add_file($file);
        $fileSec->add_fileGrp($filegrp);
    }

    $mets->add_fileSec($fileSec);
    my $structMap = StructMap->new({
        ID => "p1",
        LABEL => "Bilderfolge",
        TYPE => "physical",
    });
    my $div_root = Div->new({
        ID => "p2",
        LABEL => $self->title,
        TYPE => "Buch",
    });
    foreach my $batch (@$structmap_files) {
        next unless defined $batch->{order};
        
        my $init_args = {
            ORDER => $batch->{order},    
        };
        if ($batch->{order} == 0) {
            $init_args->{LABEL} = 'PDF';
        } elsif ($self->has_sequence) {
            $init_args->{LABEL} = $self->sequence->[$batch->{order} - 1];        
        }
        my $div = Div->new($init_args);
        foreach my $usetype ( @{$self->usetypes} ) {
            if (exists $batch->{$usetype}) {
                my $fptr = Fptr->new(
                    FILEID =>  $batch->{$usetype}->id,                                     
                ); 
                $div->add_fptr($fptr);
            }
        }
        $div_root->add_div($div);
    }
    $structMap->add_div($div_root);
    $mets->add_structMap($structMap);
    
    # add logical struct map too if we have a thesis
    if ($self->is_thesis_workflow) {
        my $structMap = StructMap->new({
            ID => "p1",
            LABEL => "Bilderfolge",
            TYPE => "logical",
        });
        my $div_root = Div->new({
            ID => "p2",
            LABEL => $self->title,
            TYPE => "Buch",
        });
        my $div = Div->new({
            ORDER => 0,    
            LABEL => 'PDF',
        });
        my $fptr = Fptr->new(
            FILEID =>  $structmap_files->[0]{reference}->id,                                     
        ); 
        $div->add_fptr($fptr);        
        $div_root->add_div($div);
        $structMap->add_div($div_root);
        $mets->add_structMap($structMap);
    }

    # add mixed struct map if we have a job file
    
    
    if ($self->has_job_file) {
        my $structMap = StructMap->new({
            ID => "p1",
            LABEL => "Sonstiges",
            TYPE => "mixed",
        });
        my $div_root = Div->new({
            ID => "p2",
            LABEL => $self->title,
            TYPE => "Buch",
        });
        my $div = Div->new({
            ORDER => 0,    
            LABEL => 'Workflow',
        });
        my $fptr = Fptr->new(
            FILEID =>  $self->job_file->id,                                     
        ); 
        $div->add_fptr($fptr);        
        $div_root->add_div($div);
        $structMap->add_div($div_root);
        $mets->add_structMap($structMap);
    }

    return $mets;
}

sub get_amdSec {
    my ($self, $id, $urn) = @_;
    
    return AmdSec->new({
        sourceMDs => [
            SourceMD->new({
                ID => $id,
                mdWraps => [
                    MdWrap->new({
                        MDTYPE => 'OTHER',
                        OTHERMDTYPE => 'preservation_md',
                        xmlDatas => [
                            XmlData->new({
                                objects => [
                                    $self->get_premis($urn),
                                ],            
                            }),
                        ],
                    }),
                ],
            }),
        ],
    });
}

sub get_niss {
    my $self = shift;
    #BVB: lower cases and no underscores
    my $order_id=$self->order_id;
    $order_id =~ s/_/-/g;
    return lc($order_id) . '-';
   
}

sub get_premis {
    my ($self, $urn) = @_;
    
    return PREMIS::Object->new({
        xmlns => 'http://www.loc.gov/standards/premis',
        objectIdentifiers => [
            PREMIS::ObjectIdentifier->new({
                objectIdentifierTypes => [
                    PREMIS::ObjectIdentifierType->new({
                        text => 'URN',                                
                    }),                              
                ],
                objectIdentifierValues =>[
                    PREMIS::ObjectIdentifierValue->new({
                        text => $urn,
                    }),                          
                ],
            }),                      
        ],
    });
}

__PACKAGE__->meta->make_immutable;

1;
