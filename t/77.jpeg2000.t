use utf8;
use strict;
use warnings;
use FindBin qw($Bin);
use Path::Tiny;
use lib path($Bin)->child('lib')->stringify,
        path($Bin)->parent->child('lib')->stringify;
use Test::More;
# use Devel::Leak::Object qw{ GLOBAL_bless };
# $Devel::Leak::Object::TRACKSOURCELINES = 1;
use Data::Dumper;
use File::Spec;

BEGIN {
    use_ok( 'Remedi::JPEG2000::App' ) or exit;
    use_ok( 'Helper' ) or exit;
}

Helper::prepare_input_files({
    input_dir =>  path($Bin, 'input_files'),
    rmdir_dirs => [ qw(archive reference thumbnail ingest) ],
    make_path => [ qw(archive reference thumbnail) ],
    copy => [
        { glob => 'ubr00003_000?.tif',
          dir  => 'archive',
        },
        { glob => 'ubr00003_0001.pdf',
          dir  => 'reference',
        },        
        { glob => 'ubr00003_000?.gif',
          dir  => 'thumbnail',
        },
        { glob => 'ubr00003_000[23].tif',
          dir  => 'reference',
        },
#        { glob => 'ubr00003_0002.tif',
#          dir  => 'TIFF_to_J2K',
#        }
    ],
});

my $task = Remedi::JPEG2000::App->new(
    creator => 'Universitätsbibliothek Regensburg', 
    log_configfile => path($Bin, qw(config log4perl.conf)),
    library_union_id => 'bvb',
    isil => 'DE-355',
    image_path => '.',
    image_basepath => path($Bin, 'input_files'),
    # jpeg2000_input_dir => path($Bin, qw(input_files TIFF_to_J2K)),
    regex_filestem_prefix => qr/ubr\d{5}/,
    regex_filestem_var => qr/_\d{1,5}/,
    title => 'My Title',
);

SKIP: {
    my $response = $task->user_agent->get($task->jpeg2000_url);
    diag $task->jpeg2000_url;
    skip $response->status_line, 1 unless $response->is_success;
    ok($task->convert);
}
my $app = Log::Log4perl::Appender::TestBuffer->by_name("my_buffer");
#like($app->buffer, qr/starting \.\.\./, 'TIFF to JPEG2000 finished');
#diag $app->buffer;

done_testing();

