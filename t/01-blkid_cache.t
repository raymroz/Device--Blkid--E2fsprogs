# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Device-Blkid-E2fsprogs.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 5;
BEGIN { use_ok('Device::Blkid::E2fsprogs') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

$c = &Device::Blkid::E2fsprogs::get_cache("/etc/blkid/blkid.tab");
isa_ok( $c, 'Cache',    'Cache object match'   );
undef $c;
ok( ref($c) eq '',      'Cache object cleanup, mem freed');

$b = &Device::Blkid::E2fsprogs::dev_iterate_begin($c);
isa_ok( $b, 'DevIter',  'DevIter object match' );
undef $b;
ok( ref($b) eq '',      'DevIter object cleanup, mem freed');