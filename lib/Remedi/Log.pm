use utf8;
package Remedi::Log;

# ABSTRACT: Role for Logging in Remedi

use Moose::Role;
    
use Carp;
use Log::Log4perl qw(:levels);
use Log::Log4perl::Util::TimeTracker;
use Path::Tiny qw(path);
use MooseX::AttributeShortcuts;

use Remedi::Types qw(File Path LogLevel TimeTracker);

has 'log_config_path' => (is => 'ro', isa => Path, coerce => 1);

has 'log_config_file' => ( is => 'lazy', isa => File, init_arg => undef);

has 'log_file' => ( is => 'lazy', isa => Path );

has 'log_level' => ( is => 'rw', isa => LogLevel, coerce => 1, predicate => 1 );

has '_timer' => ( is => 'lazy', isa => TimeTracker );

sub BUILD {
    my $self = shift;
    
    $self->init_logging(@_);
}

sub _build_log_file {
    my $self = shift;
    
    my $log_path = $self->can('log_path') && $self->log_path
      || path(__FILE__)->parent(3)->child('log');
    if ( $log_path->is_dir ) {
        return $log_path->child('remedi.log');
    } elses {
        return $log_path;    
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

sub init_logging {
    my ($self, $args) = @_;
    
    $self->_timer->reset;
    my ($debug_msg, $warn_msg);
    # TODO: Has to be revised 
    if ( $self->log_config_file->is_file ) {
        Log::Log4perl->init_once( $self->log_config_file->stringify );
        my $appender = Log::Log4perl->appender_by_name('LOGFILE');
        $appender->file_switch($self->log_file->stringify)
            if $appender;
        $debug_msg = sprintf("log config file: '%s'", $self->log_config_file); 
    } else {
        Log::Log4perl->easy_init($Log::Log4perl::INFO);
        $warn_msg = sprintf("log config '%s' not found", $self->log_config_file);
        $warn_msg .= "\nInit easy logging mode";     
    }
    $self->log->level($self->log_level) if $self->has_log_level;
    $self->log->debug($debug_msg) if  $debug_msg;
    $self->log->warn($warn_msg) if  $warn_msg;
    $self->log->debug("Log file: " . $self->log_file->stringify);
    $self->log->info(sprintf("----- Start: %s -----", $self->_name));
    $self->log->info("Title: ", $self->title) if $self->can('title'); 
    $self->log->debug("----- Parameters -------------");
    foreach my $key  (sort grep { !/usage|app|log_level/ } keys %$args) {
    	$self->log->debug( sprintf("      %s => %s",$key, $args->{$key} ) );
    }
    $self->log->debug( sprintf(
            "      %s => %s", 
            'log_level', 
            Log::Log4perl::Level::to_level($self->log->level)
    ) );
    $self->log->debug("----- End parameters --------");
    $self->log->info("Working directory: " . Cwd::cwd() );
}

no Moose::Role;
1;
