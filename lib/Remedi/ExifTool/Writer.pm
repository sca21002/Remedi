use utf8;
package Remedi::ExifTool::Writer;

# ABSTRACT: Role for writing metadata tags with ExifTool

use Moose::Role;
    requires qw(log _build_tag_map);

use Image::ExifTool;
use MooseX::AttributeShortcuts;
use Remedi::ExifTool::Tag;
use Remedi::ExifTool::Tag::PDF;
use Remedi::ExifTool::Tag::XMP::dc;
use Remedi::ExifTool::Tag::XMP::xmp;
use Remedi::ExifTool::Tag::XMP::pdf;
use Remedi::Types qw(ArrayRef File HashRef ImageExifTool  ModuleName
    RemediExifToolTag Str);
use namespace::autoclean;

use Data::Printer;

has tag_class_base => (
    is => 'ro',
    isa => ModuleName,
    default => sub{ 'Remedi::ExifTool::Tag' },
);

has 'exiftool'    => (
    is => 'lazy',
    isa => ImageExifTool,
    handles => [ qw(GetValue SetNewValue WriteInfo) ] 
);

has 'file' => ( is => 'ro', isa => File, required => 1 );

has 'tag' => ( is => 'lazy', isa => RemediExifToolTag );

has tag_map => (
    is => 'ro',
    isa => HashRef[ArrayRef[Str]],
    builder => '_build_tag_map',
);

sub _build_exiftool {
    my $self = shift;
    
    my $exiftool = new Image::ExifTool;
    $exiftool->ExtractInfo( $self->file->stringify );
    return $exiftool;
}

sub _build_tag {
    my $self = shift;
    
    my $tag = Remedi::ExifTool::Tag->new();
    
    my $map_inv = $self->get_map_inverse( $self->tag_map );
    
    foreach my $groupname ( keys %$map_inv ) {
        my $class = $map_inv->{$groupname}{class};
        my $group = $class->new( $map_inv->{$groupname}{tag} );
        $tag->set_group($groupname => $group);
    }
    return $tag;
}

sub get_classname {
    my ($self, $groupname) = @_;
    
    my ($class) = $groupname =~ s/-(.*)/::\U$1/r; # substitute - with ::
    $self->tag_class_base . '::' . $class;        # and all uppercase after :: 
}

sub get_map_inverse {
    my ($self, $map) = @_;
   
    my $map_inv;
    foreach my $attr (keys %$map) {
        my $predicate = 'has_' . $attr;
        next unless $self->$predicate;
        my @tagnames = @{$map->{$attr}};
        foreach my $tagname (@tagnames) {
            my ($groupname, $tag) = split /:/, $tagname, 2;
            $map_inv->{$groupname}{class} = $self->get_classname($groupname);
            $map_inv->{$groupname}{tag}{$tag} = $self->$attr; 
        }
    }
    return $map_inv;
}

sub write {
    my ($self, $tagset) = @_;   
    
    my @groupnames = $tagset->get_groups;
    foreach my $groupname (@groupnames) {
        $self->log->trace("Writing metadata group '$groupname'");
        my $group = $tagset->get_group($groupname);
        my @tagnames = $group->meta->get_attribute_list;
        foreach my $tagname (@tagnames) {
            my $predicate = 'has_' . $tagname;
            next unless $group->$predicate;
            my $tagname_grp = "$groupname:$tagname";
            my $value = $group->$tagname;
            $self->log->trace("$tagname_grp => " . p($value));
            my ($success, $err_str) = $self->SetNewValue($tagname_grp, $value);
                die("Setting metadata '$value' for '$tagname_grp' failed: "
                    . "$err_str")
                        unless $success;
        }
    }
    $self->WriteInfo($self->file->stringify);
}
 
1; # Magic true value required at end of module

__END__