# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Device-Blkid-E2fsprogs.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 6;
BEGIN { use_ok( 'Device::Blkid::E2fsprogs', ':funcs' ) };
require_ok( 'Device::Blkid::E2fsprogs' );

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

$c = get_cache("/etc/blkid/blkid.tab");
isa_ok( $c,                             'Cache',                   'Cache object match' );
$b = probe_all($c);
isa_ok( $b,                             'Cache',         'Cache matched on probe_all()' );
$a = probe_all_new($c);
isa_ok( $a,                             'Cache',     'Cache matched on probe_all_new()' );
undef $c;
ok( ref($c) eq '',      'Cache object cleanup, mem freed');
