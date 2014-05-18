use utf8;
use strict;
use warnings;
use FindBin qw($Bin);
use Path::Tiny;
use lib path($Bin)->child('lib')->stringify,
        path($Bin)->parent->child('lib')->stringify;
use Test::More;

BEGIN {
    use_ok( 'Remedi::PDF::API2' ) or exit;
    use_ok( 'Helper' ) or exit;
}

Helper::prepare_input_files({
    input_dir =>  path($Bin, 'input_files'),
    copy => [ qw(ubr00003.pdf ubr00003_with_pagelabels.pdf) ],
});

my $pdf_w_pl = Remedi::PDF::API2->open(
    file => path( $Bin, qw(input_files ubr00003_with_pagelabels.pdf) ),
);

is($pdf_w_pl->size, '384472', 'size');
is($pdf_w_pl->pages,'3', 'number of pages');

is ($pdf_w_pl->pagelabels->has_pagelabels, 2, "pagelabels count");
is ($pdf_w_pl->pagelabels->get(1)->style, 'decimal', "pagelabel style"  );
is ($pdf_w_pl->pagelabels->get(1)->page_no, 1,       "pagelabel page_no");
is ($pdf_w_pl->pagelabels->get(1)->prefix, 'Seite ', "pagelabel prefix" );
is ($pdf_w_pl->pagelabels->get(1)->start, 2,         "pagelabel start"  );



#foreach my $label ($pdf->pagelabels->all) {
#    foreach my $el ( qw(page_no style prefix start) ) {
#        print "$el: '", $label->$el, "'\n";
#    }
#}

my $pdf = Remedi::PDF::API2->open(
    file => path( $Bin, qw(input_files ubr00003.pdf) ),
);
is ($pdf->pagelabels, undef, "has no pagelabels");

my $page = $pdf_w_pl->openpage(3);
isa_ok($page,'Remedi::PDF::API2::Page');
my $image = $page->images->[0];
isa_ok($image, 'Remedi::PDF::API2::Image');
is($image->height, 691, 'image height');
is($image->width, 430, 'image width');

done_testing();