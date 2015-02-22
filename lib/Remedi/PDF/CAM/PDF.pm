package Remedi::PDF::CAM::PDF;

# ABSTRACT: Class for a pdf based on CAM::PDF 

use Moose;
use CAM::PDF;
use MooseX::AttributeShortcuts;
use MooseX::Types::Path::Tiny qw(File);
use MooseX::Types::Moose qw(Any Int Str);
use Path::Tiny;
use namespace::autoclean;


has 'file' => (
    is => 'ro',
    isa => File,
    required => 1,
    coerce => 1,
);

has 'pdfinfo'    => ( is => 'lazy', isa => Any );
has 'pdfversion' => ( is => 'lazy', isa => Str );
has 'size'       => ( is => 'lazy', isa => Int );

has '_pdf'       => ( is => 'lazy', isa => 'CAM::PDF',
    handles => [ qw(dereference getPageContent getPageText getValue numPages)],
);

sub _build_size {
    my $self = shift;
    
    return length $self->_pdf->{content};
}

sub _build_pdfinfo {
    my $self = shift;
    
    my $pdfinfo = $self->_pdf->{trailer}->{Info};
    $pdfinfo &&= $self->_pdf->getValue($pdfinfo);
    my %info = map { $_, $pdfinfo->{$_}->{value} } keys %$pdfinfo;
    return \%info;
}

sub _build_pdfversion {
    my $self = shift;
    
    return $self->_pdf->{pdfversion};
}

#sub _build_pages {
#    my $self = shift;
#    
#    my @pages;
#    foreach my $pageno (1 .. $self->numPages) {
#        my $page = Remedi::PDF::Page->new(
#            pdf => $self->_pdf,
#            pageno => $pageno
#        );
#        push @pages, $page;
#    }
#    return \@pages;
#}

sub _build__pdf {
    my $self = shift;
    
    return CAM::PDF->new($self->file->stringify);
}

sub create_thumbnail {
    my ($self, $thmb_path) = @_;

    foreach my $objnum (keys %{$self->_pdf->{xref}}) {
        my $xobj = $self->dereference($objnum);
        if ($xobj->{value}->{type} eq 'dictionary') {
            my $im = $xobj->{value}->{value};
            if (exists $im->{Type} && $self->getValue($im->{Type}) eq 'XObject' &&
                exists $im->{Subtype} && $self->getValue($im->{Subtype}) eq 'Image') {
                my $ref = '(no name)';
                if ($im->{Name}) {
                    $ref = $self->getValue($im->{Name});
                }
                my $w = $im->{Width} || $im->{W} || 0;
                if ($w) {
                    $w = $self->getValue($w);
                }
                my $h = $im->{Height} || $im->{H} || 0;
                if ($h) {
                    $h = $self->getValue($h);
                }
    
                my $oldsize = $self->getValue($im->{Length});
                if (!$oldsize) {
                    die "PDF error: Failed to get size of image\n";
                }
                my $tmpl = Remedi::PDF::CAM::PDF->new(
                    file => path(__FILE__)->parent(5)->child(qw(config crunchjpg_tmpl.pdf)),
                );
    
                # Get a handle on the needed data bits from the template
                my $media_array = $tmpl->getValue($tmpl->_pdf->getPage(1)->{MediaBox});
                my $rawpage = $tmpl->getPageContent(1);
    
                $media_array->[2]->{value} = $w;
                $media_array->[3]->{value} = $h;
                my $page = $rawpage;
                $page =~ s/xxx/$w/igxms;
                $page =~ s/yyy/$h/igxms;
                $tmpl->_pdf->setPageContent(1, $page);
                $tmpl->_pdf->replaceObject(9, $self->_pdf, $objnum, 1);
    
                my $ofile = Path::Tiny->tempfile();
                $tmpl->_pdf->cleanoutput($ofile->stringify);
               
                Remedi::ImageMagickCmds::create_thumbnail(
                    $ofile->absolute->stringify,
                    'GIF',
                    $thmb_path,
                    300,
                );
                last;
            }      
        }
    }
}    


__PACKAGE__->meta->make_immutable;

1;
