#! /usr/local/bin/perl -w

# vim: tabstop=4
# vim: syntax=perl

use strict;

use Test;

BEGIN {
	plan tests => 7;
}

use Locale::Recode;

sub int2utf8;

my $local2ucs = {};
my $ucs2local = {};

while (<DATA>) {
	my ($code, $ucs, undef) = map { oct $_ } split /\s+/, $_;
	$local2ucs->{$code} = $ucs;
	$ucs2local->{$ucs} = $code unless $ucs == 0xfffd;
}

my $cd_int = Locale::Recode->new (from => 'KOI-8',
				  to => 'INTERNAL');
ok !$cd_int->getError;

my $cd_utf8 = Locale::Recode->new (from => 'KOI-8',
				   to => 'UTF-8');
ok !$cd_utf8->getError;

my $cd_rev = Locale::Recode->new (from => 'INTERNAL',
				  to => 'KOI-8');
ok !$cd_rev->getError;

# Convert into internal representation.
my $result_int = 1;
while (my ($code, $ucs) = each %$local2ucs) {
    my $outbuf = chr $code;
    my $result = $cd_int->recode ($outbuf);
    unless ($result && $outbuf->[0] == $ucs) {
	$result_int = 0;
	last;
    }
}
ok $result_int;

# Convert to UTF-8.
my $result_utf8 = 1;
while (my ($code, $ucs) = each %$local2ucs) {
    my $outbuf = chr $code;
    my $result = $cd_utf8->recode ($outbuf);
    unless ($result && $outbuf eq int2utf8 $ucs) {
        $result_utf8 = 0;
        last;
    }
}
ok $result_utf8;

# Convert from internal representation.
my $result_rev = 1;
while (my ($ucs, $code) = each %$ucs2local) {
    my $outbuf = [ $ucs ];
    my $result = $cd_rev->recode ($outbuf);
    unless ($result && $code == ord $outbuf) {
        $result_int = 0;
        last;
    }
}
ok $result_int;

# Check handling of unknown characters.
my $test_string1 = [ unpack 'c*', ' Supergirl ' ];
$test_string1->[0] = 0xad0be;
$test_string1->[-1] = 0xad0be;
my $test_string2 = [ unpack 'c*', 'Supergirl' ];

my $unknown = "\x3f"; # Unknown character!

$cd_rev = Locale::Recode->new (from => 'INTERNAL',
		               to => 'KOI-8',
				)
&& $cd_rev->recode ($test_string1)
&& $cd_rev->recode ($test_string2)
&& ($test_string2 = $unknown . $test_string2 . $unknown);

ok $test_string1 eq $test_string2;

sub int2utf8
{
    my $ucs4 = shift;
    
    if ($ucs4 <= 0x7f) {
	return chr $ucs4;
    } elsif ($ucs4 <= 0x7ff) {
	return pack ("C2", 
		     (0xc0 | (($ucs4 >> 6) & 0x1f)),
		     (0x80 | ($ucs4 & 0x3f)));
    } elsif ($ucs4 <= 0xffff) {
	return pack ("C3", 
		     (0xe0 | (($ucs4 >> 12) & 0xf)),
		     (0x80 | (($ucs4 >> 6) & 0x3f)),
		     (0x80 | ($ucs4 & 0x3f)));
    } elsif ($ucs4 <= 0x1fffff) {
	return pack ("C4", 
		     (0xf0 | (($ucs4 >> 18) & 0x7)),
		     (0x80 | (($ucs4 >> 12) & 0x3f)),
		     (0x80 | (($ucs4 >> 6) & 0x3f)),
		     (0x80 | ($ucs4 & 0x3f)));
    } elsif ($ucs4 <= 0x3ffffff) {
	return pack ("C5", 
		     (0xf0 | (($ucs4 >> 24) & 0x3)),
		     (0x80 | (($ucs4 >> 18) & 0x3f)),
		     (0x80 | (($ucs4 >> 12) & 0x3f)),
		     (0x80 | (($ucs4 >> 6) & 0x3f)),
		     (0x80 | ($ucs4 & 0x3f)));
    } else {
	return pack ("C6", 
		     (0xf0 | (($ucs4 >> 30) & 0x3)),
		     (0x80 | (($ucs4 >> 24) & 0x1)),
		     (0x80 | (($ucs4 >> 18) & 0x3f)),
		     (0x80 | (($ucs4 >> 12) & 0x3f)),
		     (0x80 | (($ucs4 >> 6) & 0x3f)),
		     (0x80 | ($ucs4 & 0x3f)));
    }
}

#Local Variables:
#mode: perl
#perl-indent-level: 4
#perl-continued-statement-offset: 4
#perl-continued-brace-offset: 0
#perl-brace-offset: -4
#perl-brace-imaginary-offset: 0
#perl-label-offset: -4
#tab-width: 4
#End:


__DATA__
0x00	0x0000
0x01	0x0001
0x02	0x0002
0x03	0x0003
0x04	0x0004
0x05	0x0005
0x06	0x0006
0x07	0x0007
0x08	0x0008
0x09	0x0009
0x0a	0x000a
0x0b	0x000b
0x0c	0x000c
0x0d	0x000d
0x0e	0x000e
0x0f	0x000f
0x10	0x0010
0x11	0x0011
0x12	0x0012
0x13	0x0013
0x14	0x0014
0x15	0x0015
0x16	0x0016
0x17	0x0017
0x18	0x0018
0x19	0x0019
0x1a	0x001a
0x1b	0x001b
0x1c	0x001c
0x1d	0x001d
0x1e	0x001e
0x1f	0x001f
0x20	0x0020
0x21	0x0021
0x22	0x0022
0x23	0x0023
0x24	0x0024
0x25	0x0025
0x26	0x0026
0x27	0x0027
0x28	0x0028
0x29	0x0029
0x2a	0x002a
0x2b	0x002b
0x2c	0x002c
0x2d	0x002d
0x2e	0x002e
0x2f	0x002f
0x30	0x0030
0x31	0x0031
0x32	0x0032
0x33	0x0033
0x34	0x0034
0x35	0x0035
0x36	0x0036
0x37	0x0037
0x38	0x0038
0x39	0x0039
0x3a	0x003a
0x3b	0x003b
0x3c	0x003c
0x3d	0x003d
0x3e	0x003e
0x3f	0x003f
0x40	0x0040
0x41	0x0041
0x42	0x0042
0x43	0x0043
0x44	0x0044
0x45	0x0045
0x46	0x0046
0x47	0x0047
0x48	0x0048
0x49	0x0049
0x4a	0x004a
0x4b	0x004b
0x4c	0x004c
0x4d	0x004d
0x4e	0x004e
0x4f	0x004f
0x50	0x0050
0x51	0x0051
0x52	0x0052
0x53	0x0053
0x54	0x0054
0x55	0x0055
0x56	0x0056
0x57	0x0057
0x58	0x0058
0x59	0x0059
0x5a	0x005a
0x5b	0x005b
0x5c	0x005c
0x5d	0x005d
0x5e	0x005e
0x5f	0x005f
0x60	0x0060
0x61	0x0061
0x62	0x0062
0x63	0x0063
0x64	0x0064
0x65	0x0065
0x66	0x0066
0x67	0x0067
0x68	0x0068
0x69	0x0069
0x6a	0x006a
0x6b	0x006b
0x6c	0x006c
0x6d	0x006d
0x6e	0x006e
0x6f	0x006f
0x70	0x0070
0x71	0x0071
0x72	0x0072
0x73	0x0073
0x74	0x0074
0x75	0x0075
0x76	0x0076
0x77	0x0077
0x78	0x0078
0x79	0x0079
0x7a	0x007a
0x7b	0x007b
0x7c	0x007c
0x7d	0x007d
0x7e	0x007e
0x7f	0x007f
0xc0	0xfffd
0xc0	0xfffd
0xc0	0xfffd
0xc0	0xfffd
0xc0	0xfffd
0xc0	0xfffd
0xc0	0xfffd
0xc0	0xfffd
0xc0	0xfffd
0xc0	0xfffd
0xc0	0xfffd
0xc0	0xfffd
0xc0	0xfffd
0xc0	0xfffd
0xc0	0xfffd
0xc0	0xfffd
0xc0	0xfffd
0xc0	0xfffd
0xc0	0xfffd
0xc0	0xfffd
0xc0	0xfffd
0xc0	0xfffd
0xc0	0xfffd
0xc0	0xfffd
0xc0	0xfffd
0xc0	0xfffd
0xc0	0xfffd
0xc0	0xfffd
0xc0	0xfffd
0xc0	0xfffd
0xc0	0xfffd
0xc0	0xfffd
0xc0	0xfffd
0xc0	0xfffd
0xc0	0xfffd
0xc0	0xfffd
0xc0	0xfffd
0xc0	0xfffd
0xc0	0xfffd
0xc0	0xfffd
0xc0	0xfffd
0xc0	0xfffd
0xc0	0xfffd
0xc0	0xfffd
0xc0	0xfffd
0xc0	0xfffd
0xc0	0xfffd
0xc0	0xfffd
0xc0	0xfffd
0xc0	0xfffd
0xc0	0xfffd
0xc0	0xfffd
0xc0	0xfffd
0xc0	0xfffd
0xc0	0xfffd
0xc0	0xfffd
0xc0	0xfffd
0xc0	0xfffd
0xc0	0xfffd
0xc0	0xfffd
0xc0	0xfffd
0xc0	0xfffd
0xc0	0xfffd
0xc0	0xfffd
0xc0	0x044e
0xc1	0x0430
0xc2	0x0431
0xc3	0x0446
0xc4	0x0434
0xc5	0x0435
0xc6	0x0444
0xc7	0x0433
0xc8	0x0445
0xc9	0x0438
0xca	0x0439
0xcb	0x043a
0xcc	0x043b
0xcd	0x043c
0xce	0x043d
0xcf	0x043e
0xd0	0x043f
0xd1	0x044f
0xd2	0x0440
0xd3	0x0441
0xd4	0x0442
0xd5	0x0443
0xd6	0x0436
0xd7	0x0432
0xd8	0x044c
0xd9	0x044b
0xda	0x0437
0xdb	0x0448
0xdc	0x044d
0xdd	0x0449
0xde	0x0447
0xdf	0x044a
0xe0	0x042e
0xe1	0x0410
0xe2	0x0411
0xe3	0x0426
0xe4	0x0414
0xe5	0x0415
0xe6	0x0424
0xe7	0x0413
0xe8	0x0425
0xe9	0x0418
0xea	0x0419
0xeb	0x041a
0xec	0x041b
0xed	0x041c
0xee	0x041d
0xef	0x041e
0xf0	0x041f
0xf1	0x042f
0xf2	0x0420
0xf3	0x0421
0xf4	0x0422
0xf5	0x0423
0xf6	0x0416
0xf7	0x0412
0xf8	0x042c
0xf9	0x042b
0xfa	0x0417
0xfb	0x0428
0xfc	0x042d
0xfd	0x0429
0xfe	0x0427
0xff	0xfffd
