package Device::Blkid::E2fsprogs;

use 5.008000;
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
XSLoader::load('Device::Blkid::E2fsprogs', $VERSION);



# Preloaded methods go here.

1;
__END__

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

  # Catching exceptions with eval
  local $@;
  my $cache - eval { get_cache($cache_file) };
  if ($@) {
      # Do something, log or die
      die "Error while obtaining cache file: $@";
  }

=head1 DESCRIPTION

  NOTE: This library only exposes the older e2fsprogs versions of libblkid ( pre-2.15 ) and
  not the newer and preferred util-linux-ng versions ( v2.15 or better ). In almost
  every case you would be advised to use Friedrich Bastion's util-linux-ng based
  L<Device::Blkid> module as the newer lib interface is backward compatible with the old
  one. This module would prove useful in any situation where for any reason you are
  limited on your systems to a pre-2.15 libblkid version which is a part of the e2fsprogs
  package. Incidentally, libblkid version numbering is based upon the version of either
  util-linux-ng or e2fsprogs of which it was a part and as such, e2fsprogs based versions
  of the library were numbered v1.xx whereas util-linux-ng versions are numbered as v2.15
  or better which was the version of util-linux-ng in which it was added to that package.
  Finally, if you are under constraints which limit your selection of which library to use,
  I urge you to grab Friedrich's package L<Device::Blkid> as it supported a newer and
  larger libblkid API.

This package provides a Perl interface to libblkid as it was a part of the e2fsprogs package. It
does not support the larger and more robust API which has been added and integrated into the
libblkid library since the library was added to the util-linux-ng package. See the preceding
note for complete details.

Libblkid provides a simple way to access and evaluate LABEL and UUID tags which can be associated
with block devices. The tags are now becoming commonplace block device and volume aliases in more
modern distributions of Linux. This Perl interface exposes the various and sundry functionality
exposed by the libblkid system library to the Perl programmer.

Recognizing that this is a Perl module, I have tried to provide a more 'Perlish' interface
where possible rather than merely map Perl subs to C functions. For example, while client code
can get a Perl object reference to the underlying C structures, they are at no time able to
manipulate structure members. This decision was made as I could not conceive of any legitimate
reasons for allowing for such access. Also, where possible and relevant, I have endeavored to
return Perl-style eval-based exceptions when exceptional conditions occur inside of the underlying
C functions. The exceptions are all string style, no objects are passed. See the L</"SYNOPSIS"> above
for further details.

=head2 EXPORT

Nothing is exported by default, but constants and package functions are available as follows:

  To export libblkid defined constants, implement the following use pragma:

  use Device::Blkid::E2fsprogs qw/ :consts /;

  To export this package's functions into the namespace, implement the following use pragma:

  use Device::Blkid::E2fsprogs qw/ :funcs /;

=head1 SEE ALSO

L<E2fsprogs project home page|http://e2fsprogs.sourceforge.net/>
L<blkid(8)>
L<PerlXS|http://perldoc.perl.org/perlxs.html>
L<Device::Blkid>

This package project is also hosted on Github at
git://github.com/raymroz/Device--Blkid--E2fsprogs.git

=head1 AUTHOR

Raymond Mroz, E<lt>mroz@cpan.org<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Raymond Mroz

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.1 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

No known bugs at this time. That said, this module is largely written in C and does contain
a number of memory allocations. While these allocations are done inside of libblkid itself,
I do make every attempt to free the memory explicitly when I am done with it. That said, leaks
are possible. Please report any issues as is detailed above.


=cut
