#!/usr/bin/env perl

BEGIN {
    $ENV{CATALYST_ENGINE} ||= 'HTTP';
    $ENV{CATALYST_SCRIPT_GEN} = 39;
    require Catalyst::Engine::HTTP;
}

use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;
use FindBin;
use lib "$FindBin::Bin/../lib";

my $debug             = 0;
my $fork              = 0;
my $help              = 0;
my $host              = undef;
my $port              = $ENV{TESTAPP_PORT} || $ENV{CATALYST_PORT} || 3000;
my $keepalive         = 0;
my $restart           = $ENV{TESTAPP_RELOAD} || $ENV{CATALYST_RELOAD} || 0;
my $background        = 0;
my $pidfile           = undef;

my $check_interval;
my $file_regex;
my $watch_directory;
my $follow_symlinks;

my @argv = @ARGV;

GetOptions(
    'debug|d'             => \$debug,
    'fork|f'              => \$fork,
    'help|?'              => \$help,
    'host=s'              => \$host,
    'port|p=s'            => \$port,
    'keepalive|k'         => \$keepalive,
    'restart|r'           => \$restart,
    'restartdelay|rd=s'   => \$check_interval,
    'restartregex|rr=s'   => \$file_regex,
    'restartdirectory=s@' => \$watch_directory,
    'followsymlinks'      => \$follow_symlinks,
    'background'          => \$background,
    'pidfile=s'           => \$pidfile,
);

pod2usage(1) if $help;

if ( $debug ) {
    $ENV{CATALYST_DEBUG} = 1;
}

# If we load this here, then in the case of a restarter, it does not
# need to be reloaded for each restart.
require Catalyst;

# If this isn't done, then the Catalyst::Devel tests for the restarter
# fail.
$| = 1 if $ENV{HARNESS_ACTIVE};

my $runner = sub {
    # This is require instead of use so that the above environment
    # variables can be set at runtime.
    require TestApp;

    TestApp->run(
        $port, $host,
        {
            argv       => \@argv,
            'fork'     => $fork,
            keepalive  => $keepalive,
            background => $background,
            pidfile    => $pidfile,
        }
    );
};

if ( $restart ) {
    die "Cannot run in the background and also watch for changed files.\n"
        if $background;

    require Catalyst::Restarter;

    my $subclass = Catalyst::Restarter->pick_subclass;

    my %args;
    $args{follow_symlinks} = 1
        if $follow_symlinks;
    $args{directories} = $watch_directory
        if defined $watch_directory;
    $args{sleep_interval} = $check_interval
        if defined $check_interval;
    $args{filter} = qr/$file_regex/
        if defined $file_regex;

    my $restarter = $subclass->new(
        %args,
        start_sub => $runner,
        argv      => \@argv,
    );

    $restarter->run_and_watch;
}
else {
    $runner->();
}

1;

=head1 NAME

testapp_server.pl - Catalyst Testserver

=head1 SYNOPSIS

testapp_server.pl [options]

 Options:
   -d -debug          force debug mode
   -f -fork           handle each request in a new process
                      (defaults to false)
   -? -help           display this help and exits
      -host           host (defaults to all)
   -p -port           port (defaults to 3000)
   -k -keepalive      enable keep-alive connections
   -r -restart        restart when files get modified
                      (defaults to false)
   -rd -restartdelay  delay between file checks
                      (ignored if you have Linux::Inotify2 installed)
   -rr -restartregex  regex match files that trigger
                      a restart when modified
                      (defaults to '\.yml$|\.yaml$|\.conf|\.pm$')
   -restartdirectory  the directory to search for
                      modified files, can be set mulitple times
                      (defaults to '[SCRIPT_DIR]/..')
   -follow_symlinks   follow symlinks in search directories
                      (defaults to false. this is a no-op on Win32)
   -background        run the process in the background
   -pidfile           specify filename for pid file

 See also:
   perldoc Catalyst::Manual
   perldoc Catalyst::Manual::Intro

=head1 DESCRIPTION

Run a Catalyst Testserver for this application.

=head1 AUTHORS

Catalyst Contributors, see Catalyst.pm

=head1 COPYRIGHT

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
#!/usr/local/bin/perl -w

BEGIN { 
    $ENV{CATALYST_ENGINE} ||= 'HTTP';
    $ENV{CATALYST_SCRIPT_GEN} = 31;
    require Catalyst::Engine::HTTP;
}  

use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;
use FindBin;
use lib "$FindBin::Bin/../lib";

my $debug             = 0;
my $fork              = 0;
my $help              = 0;
my $host              = undef;
my $port              = $ENV{TESTAPP_PORT} || $ENV{CATALYST_PORT} || 3000;
my $keepalive         = 0;
my $restart           = $ENV{TESTAPP_RELOAD} || $ENV{CATALYST_RELOAD} || 0;
my $restart_delay     = 1;
my $restart_regex     = '(?:/|^)(?!\.#).+(?:\.yml$|\.yaml$|\.conf|\.pm)$';
my $restart_directory = undef;
my $follow_symlinks   = 0;

my @argv = @ARGV;

GetOptions(
    'debug|d'             => \$debug,
    'fork'                => \$fork,
    'help|?'              => \$help,
    'host=s'              => \$host,
    'port=s'              => \$port,
    'keepalive|k'         => \$keepalive,
    'restart|r'           => \$restart,
    'restartdelay|rd=s'   => \$restart_delay,
    'restartregex|rr=s'   => \$restart_regex,
    'restartdirectory=s@' => \$restart_directory,
    'followsymlinks'      => \$follow_symlinks,
);

pod2usage(1) if $help;

if ( $restart && $ENV{CATALYST_ENGINE} eq 'HTTP' ) {
    $ENV{CATALYST_ENGINE} = 'HTTP::Restarter';
}
if ( $debug ) {
    $ENV{CATALYST_DEBUG} = 1;
}

# This is require instead of use so that the above environment
# variables can be set at runtime.
require TestApp;

TestApp->run( $port, $host, {
    argv              => \@argv,
    'fork'            => $fork,
    keepalive         => $keepalive,
    restart           => $restart,
    restart_delay     => $restart_delay,
    restart_regex     => qr/$restart_regex/,
    restart_directory => $restart_directory,
    follow_symlinks   => $follow_symlinks,
} );

1;

=head1 NAME

testapp_server.pl - Catalyst Testserver

=head1 SYNOPSIS

testapp_server.pl [options]

 Options:
   -d -debug          force debug mode
   -f -fork           handle each request in a new process
                      (defaults to false)
   -? -help           display this help and exits
      -host           host (defaults to all)
   -p -port           port (defaults to 3000)
   -k -keepalive      enable keep-alive connections
   -r -restart        restart when files get modified
                      (defaults to false)
   -rd -restartdelay  delay between file checks
   -rr -restartregex  regex match files that trigger
                      a restart when modified
                      (defaults to '\.yml$|\.yaml$|\.conf|\.pm$')
   -restartdirectory  the directory to search for
                      modified files, can be set mulitple times
                      (defaults to '[SCRIPT_DIR]/..')
   -follow_symlinks   follow symlinks in search directories
                      (defaults to false. this is a no-op on Win32)
 See also:
   perldoc Catalyst::Manual
   perldoc Catalyst::Manual::Intro

=head1 DESCRIPTION

Run a Catalyst Testserver for this application.

=head1 AUTHOR

Sebastian Riedel, C<sri@oook.de>
Maintained by the Catalyst Core Team.

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
