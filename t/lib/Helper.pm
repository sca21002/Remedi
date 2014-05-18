use utf8;
package Helper;
use strict;
use warnings;
use Test::More;
use Path::Tiny;
use English qw( -no_match_vars );
use Readonly;
use File::Glob ':glob';

Readonly my $QUOTE => $OSNAME eq 'MSWin32' ? q{"} : q{};

BEGIN {
    use_ok( 'File::Path', qw(make_path remove_tree) ) or exit;
    use_ok( 'File::Copy' ) or exit;
}

sub prepare_input_files {
    my $args = shift;

    my $input_dir = $args->{input_dir} or
        die "directory for input files not given!";
    my $save_dir = path($input_dir, 'save');
    my @files = bsd_glob path($input_dir, '*.*');
    ok( unlink(@files), "deleting files in $input_dir") if (@files);
      
    if (ref $args->{rmdir_dirs} eq 'ARRAY') {
        foreach my $rmdir  (@{$args->{rmdir_dirs}}) {
            my $path = path($input_dir, $rmdir);
            ok(remove_tree($path),
                'deleting directory ' . $path
            ) if -e $path;
        }
    }
    if (ref $args->{make_path} eq 'ARRAY') {    
        foreach my $make_path  (@{$args->{make_path}}) {
            my $path = path($input_dir, $make_path);
            ok(make_path($path), 'making new directory ' . $path); 
        }
    }
    if (ref $args->{copy} eq 'ARRAY') {
        foreach my $copy (@{$args->{copy}}) {        
            if (!ref($copy)) {        
                my @files = bsd_glob path($save_dir, $copy);
                ok(copy($_, $input_dir), "copying  $_ --> $input_dir") foreach @files; 
            }
            elsif (ref $copy eq 'HASH') {
                if (exists $copy->{glob}) {
                    my @files = bsd_glob path($save_dir, $copy->{glob});
                    if ($input_dir) { 
                        my $dir = path($input_dir, $copy->{dir}) ;  
                        ok(copy($_, $dir), "copying  $_ --> $dir") foreach @files;
                    }
                } elsif (exists $copy->{source} && exists $copy->{dest}) {
                    my $source = path($save_dir,  $copy->{source});
                    my $dest   = path($input_dir, $copy->{dest}  );
                    ok( copy($source, $dest), "copying $source --> $dest" );
                }
            }
        }
    }
    if (ref $args->{burst} eq 'ARRAY') {
        foreach my $burst (@{$args->{burst}}) {
            if (ref $burst eq 'HASH') {
                if (exists $burst->{glob}) {
                    my @files = bsd_glob path($input_dir, $burst->{glob});
                    foreach my $file (@files) {
                        my $cmd = 'pdftk';
                        my $options = [
                            $file,
                            'burst',
                            'output',
                            path($input_dir, $burst->{output})->stringify,               
                        ];
                        my @args = ( $cmd, @$options );
                        # diag(join(' ', @args));
                        is(system(@args), 0, $cmd);
                    }
                }
            }
        }         
    }
}

1;


#my $input_dir = File::Spec->catfile($FindBin::Bin, 'input_files');
#my $save_dir = File::Spec->catfile($input_dir, 'save');
#
#my @files = glob File::Spec->catfile($input_dir, "*.*");
#ok(unlink @files, 'Lösche Dateien in t/input_files') if @files;
#my $dir = File::Spec->catfile($input_dir, 'archive');
#ok(remove_tree $dir, 'Lösche Verzeichnis in t/input_files/archive') if -e $dir;
#@files = glob File::Spec->catfile($save_dir,"ubr00003*.*");
#ok(copy($_, $input_dir), "Kopiere $_") foreach @files; 

