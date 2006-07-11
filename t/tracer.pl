#!/usr/bin/perl

use lib 'lib';

my $outfile    = shift;

$SIG{__WARN__} = sub
{
	open my $outfh, '>>', $outfile;
	print { $outfh } @_;
};

use Devel::TraceUse;

use Parent;
