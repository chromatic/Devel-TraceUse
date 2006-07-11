#! perl

use Module::Build;

use strict;
use warnings;

my $class = Module::Build->subclass(
	class => 'Module::Build::FilterTests',
	code  => <<'END_HERE',
	
	use File::Glob;
	use File::Spec::Functions;
	
	sub ACTION_disttest
	{
		my $self = shift;
		local $ENV{PERL_RUN_ALL_TESTS} = 1;
		$self->SUPER::ACTION_disttest( @_ );
	}
	
	sub find_test_files
	{
		my $self  = shift;
		my $tests = $self->SUPER::find_test_files( @_ );
	    
		return $tests unless $ENV{PERL_RUN_ALL_TESTS};
	
		my $test_pattern = catfile(qw( t developer *.t ) );
		unshift @$tests, File::Glob::bsd_glob( $test_pattern );
		return $tests;
	}
END_HERE
);

my $builder = $class->new(
    module_name         => 'Devel::TraceUse',
    license             => 'perl',
    dist_author         => 'chromatic <chromatic@wgz.org>',
    dist_version_from   => 'lib/Devel/TraceUse.pm',
    build_requires => {
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'Devel-TraceUse-*' ],
	no_index            => {
	       package => [ 'Foo::Bar', ]
	},
);

$builder->create_build_script();
