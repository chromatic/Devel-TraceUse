#!perl

use strict;
use warnings;

use File::Spec;

use Test::More tests => 7;

my $test_file = File::Spec->catfile( 't', 'tracer.pl' );
my $test_log  = File::Spec->catfile( 't', 'trace.log' );
my $test_path = File::Spec->catdir(  't', 'lib'       );

unlink $test_log if -e $test_log;

system( $^X, '-Mblib', "-I$test_path", $test_file, $test_log );

my @trace = do { local @ARGV = $test_log; <> };

like( $trace[0], qr/Modules used from $test_file/,
	'trace output should include name of program' );

like( $trace[1], qr/^  Parent, line 15/, '... then first dependency in order' );
unlike( $trace[2], qr/strict/,           '... but not preloaded modules' );

like( $trace[2],   qr/^    Child, line 3/, '... then its dependencies' );
unlike( $trace[3], qr/Parent/,             '... but not preloaded modules' );

like( $trace[3],   qr/^      Sibling, line 6/, '... then its dependencies' );
is( @trace, 4, '... and that is all' );

END { 1 while unlink $test_log }
