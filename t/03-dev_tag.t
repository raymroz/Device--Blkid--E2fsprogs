use File::Spec;

use Test::More tests => 7;
BEGIN { use_ok( 'Device::Blkid::E2fsprogs', qw/ :funcs :consts / ) };

#########################

$uuid = '005db70f-7650-40a8-8842-023bd78ac9a2';
$label = '/test';

$cache_file = File::Spec->rel2abs('blkid.tab.tmp');
$blk_dev    = File::Spec->rel2abs('t/img/ext3.fs');

$cache      = get_cache($cache_file);

local $@;
$device     = eval { get_dev($cache, $blk_dev, BLKID_DEV_CREATE) };
if ($@) {
    fail ('Invalid blk device file path');
}

# Verify device object type
isa_ok($device, 'Device',       'Device object match' );

$devname = dev_devname($device);
ok($devname eq $blk_dev,        'Check valid device name return');

$tag_val = get_tag_value( $cache, 'LABEL', $devname );
ok($tag_val eq $label,          'Check for LABEL match');

$tag_val = get_tag_value( $cache, 'UUID', $devname );
ok($tag_val eq $uuid,           'Check for UUID match');

$devname = get_devname($cache, 'LABEL', $label);
ok($devname eq $blk_dev,        'Check device name from LABEL');

$devname = get_devname($cache, 'UUID', $uuid);
ok($devname eq $blk_dev,        'Check device name from UUID');
