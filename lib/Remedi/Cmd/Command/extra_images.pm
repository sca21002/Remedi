use utf8;
package Remedi::Cmd::Command::extra_images;

# ABSTRACT: Command class for command create_thumbnail

use Moose;

extends qw(MooseX::App::Cmd::Command);

with qw(
    MooseX::SimpleConfig
    MooseX::Getopt
);

use Log::Log4perl qw(:easy);
use MooseX::Types::Path::Tiny qw(File);
use Path::Tiny;
use namespace::autoclean;

has file => ( is => 'ro', isa => File, required => 1, coerce => 1);


sub BUILD {
    my $self = shift;
    
    my $logfile = path(__FILE__)->parent(4)->child('extra_images.log');

    ### Logdatei initialisieren
    Log::Log4perl->easy_init(
        { level   => $DEBUG,
          file    => ">" . $logfile,
        },
        { level   => $TRACE,
          file    => 'STDOUT',
        },
    );

}



sub execute {
    my ( $self, $opt, $args ) = @_;

    # you may ignore $opt, it's in the attributes anyway

    my $pdf = Remedi::PDF::CAM::PDF->new(
        file => $self->file,
    );

    INFO("Pages: ", $pdf->numPages());
    
    my $cb = sub { 
        my $msg = shift;
        INFO("    $msg");
    };
    
    my $xt_images = $pdf->extra_images($cb);    
    my $output;
    foreach my $xt_image (@$xt_images) {
        my ($page, $im_cnt) = each(%$xt_image);
        $output .= "Page $page: $im_cnt extra image(s)\n";
    }
    $output .= '     No extra images found' unless $output;
    $output = "---------- Extra Images ----------\n" 
            . $output
            . "-------------- Ende --------------\n";    

    INFO($output);
}

__PACKAGE__->meta->make_immutable;
1;
