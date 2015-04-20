use utf8;
package Remedi::Log;

# ABSTRACT: Role for Logging in Remedi

use Moose::Role;
    
use Carp;
use Log::Log4perl qw(:levels);
use Log::Log4perl::Util::TimeTracker;
use Path::Tiny qw(path);
use MooseX::AttributeShortcuts;

use Remedi::Types qw(File Path LogLevel LogLog4perlLogger TimeTracker);

has 'log_config_path' => (is => 'ro', isa => Path, coerce => 1);

has 'log_config_file' => ( is => 'lazy', isa => File, init_arg => undef);

has 'log_path' => ( is => 'ro', isa => Path, coerce => 1);  

has 'log_file' => ( is => 'lazy', isa => File, init_arg => undef );

has 'log_level' => ( is => 'rw', isa => LogLevel, coerce => 1, predicate => 1 );

my @methods = qw(
    trace debug info warn error fatal
    is_trace is_debug is_info is_warn is_error is_fatal
    logexit logwarn error_warn logdie error_die
    logcarp logcluck logcroak logconfess
);

has log => (
    is => 'lazy',
    isa => 'Log::Log4perl::Logger',
    handles => \@methods,
);

around $_ => sub {
    my $orig = shift;
    my $this = shift;

    # one level for this method itself
    # two levels for Class:;MOP::Method::Wrapped (the "around" wrapper)
    # one level for Moose::Meta::Method::Delegation (the "handles" wrapper)
    local $Log::Log4perl::caller_depth;
    $Log::Log4perl::caller_depth += 4;

    my $return = $this->$orig(@_);

    $Log::Log4perl::caller_depth -= 4;
    return $return;

} foreach @methods;

has '_timer' => ( is => 'lazy', isa => TimeTracker );

sub _build_log_file {
    my $self = shift;
    
    my $log_path = $self->log_path
      || path(__FILE__)->parent(3)->child('log');
    if ( $log_path->is_dir ) {
        return $log_path->child('remedi.log');
    } elses {
        return $log_path->touch;    
    } 
}

sub _build_log_config_file {
    my $self = shift;
    
    my $log_config_path = $self->log_config_path
        || path(__FILE__)->parent(3)->child( qw( config log4perl.conf));
    if ( $log_config_path->is_dir ) {
        return $log_config_path->child('log4perl.conf');
    } elsif ($log_config_path->is_file) {
        return $log_config_path;    
    } else {
        croak "'$log_config_path' not found";
    }
}

sub _build__timer { Log::Log4perl::Util::TimeTracker->new() }

sub _build_log {
    my $self = shift;
    
    $self->_timer->reset;
    Log::Log4perl->init_once( $self->log_config_file->stringify );
    my $appender = Log::Log4perl->appender_by_name('LOGFILE');
    $appender->file_switch($self->log_file->stringify)
        if $appender;
    $self->log->level($self->log_level) if $self->has_log_level;
    my $loggerName = ref($self);
    return Log::Log4perl->get_logger($loggerName);
}

no Moose::Role;
1;
