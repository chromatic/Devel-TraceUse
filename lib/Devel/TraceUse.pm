package DB;

# allow -d:TraceUse loading with this little C++-style no-op
sub DB {}

package Devel::TraceUse;

use strict;
use warnings;

use vars '$VERSION';
$VERSION = '1.00';

use Time::HiRes qw( gettimeofday tv_interval );

BEGIN
{
	unshift @INC, \&trace_use unless grep { "$_" eq \&trace_use . '' } @INC;
}

my @used;

sub trace_use
{
	my ( $code, $module )      = @_;
	( my $mod_name = $module ) =~ s{/}{::}g;
	$mod_name                  =~ s/\.pm$//;

	my ( $package, $filename, $line ) = caller();
	my $elapsed                       = 0;

	{
		local *INC     = [ @INC[ 1 .. $#INC ] ];
		my $start_time = [ gettimeofday() ];
		eval "package $package; require '$mod_name';";
		$elapsed       = tv_interval($start_time);
	}

	$package = $filename if $package eq 'main';

	push @used,
	{
		'file'   => $package,
		'line'   => $line,
		'time'   => $elapsed,
		'module' => $mod_name,
	};

	return;
}

END
{
	my $first = $used[0];
	my %seen  = ( $first->{file} => 1 );
	my $pos   = 1;

	warn "Modules used from $first->{file}:\n";

	for my $mod (@used)
	{
		my $message = '';

		if ( exists $seen{ $mod->{file} } )
		{
			$pos = $seen{ $mod->{file} };
		}
		else
		{
			$seen{ $mod->{file} } = ++$pos;
		}

		my $indent = '  ' x $pos;
		$message  .= "$indent$mod->{module}, line $mod->{line}";
		$message  .= " ($mod->{time})" if $mod->{time};
		warn "$message\n";
	}
}

1;
__END__

=head1 NAME

Devel::TraceUse - show the modules your program loads, recursively

=head1 SYNOPSIS

An apparently simple program may load a lot of modules.  That's useful, but
sometimes you may wonder exactly which part of your program loads which module.

C<Devel::TraceUse> can analyze a program to see which part used which module.
I recommend using it from the command line:

  $ B<perl -d:TraceUse your_program.pl>

This will display a tree of the modules ultimately used to run your program.
(It also runs your program with only a little startup cost all the way through
to the end.)

  Modules used from your_program.pl:
  Test::MockObject::Extends, line 6 (0.000514)
    Test::MockObject, line 6 (0.000408)
      Scalar::Util, line 9 (0.000521)
        List::Util, line 12 (0.000393)
          XSLoader, line 24 (0.000396)
      UNIVERSAL::isa, line 10 (0.000436)
        UNIVERSAL, line 8 (0.000247)
      UNIVERSAL::can, line 11 (0.000428)
      Test::Builder, line 13 (0.000413)
    Devel::Peek, line 8 (0.000693)

=head1 AUTHOR

chromatic, C<< <chromatic at wgz.org> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-devel-traceuse at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Devel-TraceUse>.  We can both track it there.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Devel::TraceUse

You can also look for information at:

=over 4

=item * I<Perl Hacks>, hack #74

O'Reilly Media, 2006.

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Devel-TraceUse>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Devel-TraceUse>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Devel-TraceUse>

=item * Search CPAN

L<http://search.cpan.org/dist/Devel-TraceUse>

=back

=head1 COPYRIGHT & LICENSE

Copyright 2006 chromatic, most rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
