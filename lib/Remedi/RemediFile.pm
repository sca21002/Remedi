use utf8;
package Remedi::RemediFile;

# ABSTRACT: Base class for a file

use Moose;
    with qw(MooseX::Log::Log4perl);    
use MooseX::AttributeShortcuts;
use Path::Tiny 0.027 ();   # 0.027 because of method digest   
use Remedi::Types qw(File Int RemediRegexpRef Str);
use namespace::autoclean;

has 'filestem'     => ( is => 'lazy', isa => Str );

has 'file' => (
    is => 'ro',
    isa => File,   # checks if the file exists in file system
    required => 1,
    handles => [ qw(absolute basename parent stringify) ],
    coerce  => 1,
);

has 'id'           => ( is => 'lazy', isa => Str );
has 'index'        => ( is => 'lazy', isa => Int ); 
has 'md5_checksum' => ( is => 'lazy', isa => Str );
has 'order_id'     => ( is => 'lazy', isa => Str );
has 'path_abs_str' => ( is => 'lazy', isa => Str );

has 'regex_filestem_prefix' => (
    is => 'ro',
    isa => RemediRegexpRef,
    required => 1,
    coerce => 1
);  
has 'regex_filestem_var' => (
    is => 'ro',
    isa => RemediRegexpRef,
    required => 1,
    coerce => 1
);  

has 'size'         => ( is => 'lazy', isa => Str );

sub _build_filestem {
    my $self = shift;
    
    my ($filestem) = $self->basename =~ qr/(.*)\.[^.]*$/;
    return $filestem;
}

sub _build_id {
    my $self = shift;
    
    my $id = lc $self->basename;
    $id =~ s/\./_/g;
    return $id . '_file';
}

sub _build_index {
    my $self = shift;

    my $order_id =   $self->order_id;
    my $reg_var    = $self->regex_filestem_var;
    my ($var) = $self->filestem =~ /${order_id}($reg_var)/;
    if ($var) {
        my ($index) = $var =~ /(\d+)/ or
            $self->log->logcroak(
                "Couldn't get a count from file: " . $self->path_abs_str
                . "with regular expression: " . $reg_var
            );
        return sprintf("%d", $index);
    } else {
        return 0;
    }
}

sub _build_md5_checksum { shift->file->digest('MD5') };

sub _build_order_id {
    my $self = shift;

    my $reg = $self->regex_filestem_prefix; 
    my ($order_id) = $self->filestem =~ qr{($reg)}
        or $self->log->logcroak(
            "Couldn't get an order_id from file: " . $self->path_abs_str
            . "with regular expression: " . $reg
        );
    return $order_id;        
}

sub _build_path_abs_str { shift->absolute->stringify }

sub _build_size { -s shift->file }

__PACKAGE__->meta->make_immutable;

1;
