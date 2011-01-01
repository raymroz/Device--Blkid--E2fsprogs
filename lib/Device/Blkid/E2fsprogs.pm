package Device::Blkid::E2fsprogs;

use 5.010001;
use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = (
    'consts' => [ qw(
                        BLKID_DEV_FIND
                        BLKID_DEV_CREATE
                        BLKID_DEV_VERIFY
                        BLKID_DEV_NORMAL
                    ) ],
    'funcs' => [ qw(
                       blkid_get_cache
                       blkid_get_devname
                       ) ],
);
Exporter::export_ok_tags('consts');
Exporter::export_ok_tags('funcs');

our $VERSION = '0.01';

require XSLoader;
XSLoader::load('Blkid', $VERSION);



# Preloaded methods go here.

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Device::Blkid::E2fsprogs - Perl interface to e2fsprogs versions of libblkid

=head1 SYNOPSIS

  use Device::Blkid::E2fsprogs qw/ :funcs /;

  # Get a cache object from libblkid
  my $cache_file = '/etc/blkid/blkid.tab';
  my $cache = get_cache($cache_file);

  # Get the device associated with a given blkid LABEL
  my $type = 'LABEL';
  my $label = 'SWAP';

  # Using the cache
  my $device = get_devname($type, $value, $cache);

  # Bypass cache entries, poll library directly
  my $device = get_devname($type, $value);

=head1 DESCRIPTION

NOTE: This library only exposes the older e2fsprogs versions of libblkid ( pre v2.16 ) and
      not the newer and preferred util-linux-ng versions ( v 2.16 or better ). In almost
      every case you would be advised to use Friedrich Bastion's util-linux-ng based
      L<Device::Blkid> module as the newer lib interface is backward compatible with the old
      one. This module would prove useful in any situation where for any reason you are
      limited on your systems to libblkid v2.15 or earlier which is a part of the e2fsprogs
      package. If you are under no such constraints, I urge you to grab Friedrich's package
      L<Device::Blkid>. You have been warned. 

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

L<E2fsprogs project home page|http://e2fsprogs.sourceforge.net/>
L<blkid(8)>
L<PerlXS|http://perldoc.perl.org/perlxs.html>
L<Device::Blkid>

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Raymond Mroz, E<lt>mroz@cpan.org<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Raymond Mroz

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.1 or,
at your option, any later version of Perl 5 you may have available.


=cut
