package Device::Blkid::E2fsprogs;

our $VERSION = '0.10';

use 5.008000;
use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = (
    'consts' => [
        qw(
          BLKID_DEV_FIND
          BLKID_DEV_CREATE
          BLKID_DEV_VERIFY
          BLKID_DEV_NORMAL
          )
    ],
    'funcs' => [
        qw(
          put_cache
          get_cache
          gc_cache
          dev_devname
          dev_iterate_begin
          dev_set_search
          dev_next
          dev_iterate_end
          devno_to_devname
          probe_all
          probe_all_new
          get_dev
          get_dev_size
          known_fstype
          verify
          get_tag_value
          get_devname
          tag_iterate_begin
          tag_next
          tag_iterate_end
          dev_has_tag
          find_dev_with_tag
          parse_tag_string
          parse_version_string
          get_library_version
          )
    ],
);
Exporter::export_ok_tags('consts');
Exporter::export_ok_tags('funcs');

use constant BLKID_DEV_FIND   => 0x0000;
use constant BLKID_DEV_CREATE => 0x0001;
use constant BLKID_DEV_VERIFY => 0x0002;
use constant BLKID_DEV_NORMAL => ( BLKID_DEV_CREATE | BLKID_DEV_VERIFY );

require XSLoader;
XSLoader::load( 'Device::Blkid::E2fsprogs', $VERSION );

1;
__END__

=head1 NAME

Device::Blkid::E2fsprogs - Perl interface to e2fsprogs versions (1.xx.xx) of libblkid

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

  NOTE: This library only exposes the older e2fsprogs versions of libblkid ( numbered 1.xx.xx)
  and not the newer and preferred util-linux-ng versions ( v2.15 or better ). In almost
  every case you would be advised to use Friedrich Bastion's util-linux-ng based
  L<Device::Blkid> module as the newer lib interface is (mostly) backward compatible with the
  old one. This module would prove useful in any situation where for any reason you are
  limited on your systems to a 1.xx.xx libblkid version which is a part of the e2fsprogs
  package. Incidentally, libblkid version numbering is based upon the version of either
  util-linux-ng or e2fsprogs of which it was a part and as such, e2fsprogs based versions
  of the library were all numbered v1.xx.xx whereas util-linux-ng versions are numbered as v2.15
  or better which was the version of util-linux-ng in which it was added to that package.
  So just to be clear, when in doubt you are advised to grab Friedrich's newer util-linux-ng
  based libblkid interface module unless you have some specific reason as to why you can't,
  perhaps something similar to what led me to write this version.

  This version is designed in the back end somewhat differently than Friedrichs util-linux-ng
  build of the library. He opted to keep much of his logic and processing in XSUB, mine is done
  mostly in C; I have only used XSUB for my straight glue, everything else I kept in C. This is
  not to be taken as any opinion of statement on PerlXS/XSUB, its merely a reflection of my own
  background and tastes.

This package provides a Perl interface to the v1.xx.xx e2fsprogs-based versions of libblkid. It does
not support the larger and more robust API which has been added and integrated into the libblkid
library since its inclusion in the util-linux-ng package. See the preceding note for further details.

Libblkid provides a clean and intuitive way of accessing block device topology on a system. It presents
a common, unified approach to addressing, labelling and tagging various and sundry block devices in
a standardized, mnemonic fashion and provides for a more familiar feel when dealing with various
block devices and volumes. It also exposes basic file system query operations as well. There is an
ever growing selection of software and utilities which now rely on libblkid and as more modern
distributions of Linux migrate to lvm aware graphical installers, it is now standard fare.

Recognizing that this is a Perl module, I have tried to provide a more 'Perlish' interface
where possible rather than merely map Perl subs to C functions. For example, while client code
can get a Perl object reference to the underlying C structures, they are at no time able to
manipulate structure members. This decision was made as I could not conceive of any legitimate
reasons for allowing for such access. In addition, rather than return C-like bools or binary
return logic, I have, where the implementation lent itself, opted to return NULLs (mapped to
undef via XSUB glue) and hash types when mutable C pointer parameters were provided in the
C library.

Please read the README file in the package archive for instructions should you encounter any
problems while using this software package, as well as for instructions on building a debug
version of this package.

Finally, the e2fsprogs-based iterations of this library did infact grow in size over time. This
package is fully compliant with versions of e2fsprogs at about 1.40.xx. I will, through the magic
of conditional compilation with the C preprocessor, eventually support much older versions of the
library and expose the choice of build to the end user by passing a version arg in to the
Makefile.PL package within.

=head2 DEPENDENCIES

L<E2fsprogs project home page|http://e2fsprogs.sourceforge.net/>

=head2 EXPORT

Nothing is exported by default, but constants and package functions are available as follows:

  To export libblkid defined constants, implement the following use pragma:

  use Device::Blkid::E2fsprogs qw/ :consts /;

  To export this package's functions into the namespace, implement the following use pragma:

  use Device::Blkid::E2fsprogs qw/ :funcs /;

=head2 CONSTANTS

=over 4

=item  C<BLKID_DEV_CREATE>

Create and empty device structure if not found in the cache.

=item C<BLKID_DEV_VERIFY>

Make sure the device structure corresponds with reality.

=item C<BLKID_DEV_FIND>

Just look up a device entry and return NULL (undef) if not found.

=item C<BLKID_DEV_NORMAL>

Get a valid device structure, either from the cache or by probing the block device.

=back

=head2 FUNCTIONS

=over 4

=item C<put_cache($cache)>

Write any changes to the blkid cache file.

=item C<get_cache($filename)>

Given a path to a cache file, return a blkid cache object reference. This reference is of type
C<Device::Blkid::E2fsprogs::Cache>. While this object represents an underlying C struct, it is
immutable for all intents and purposes for the Perl programmer. Returns undef on fail.

=item C<gc_cache($cache)>

Calling this performs a garbage cleanup on the specified cache by removing all non-existant devices.

=item C<dev_devname($device)>

Given a blkid device object, returns a string representation of the device (e.g., /dev/sda9), undef
if something went wrong. Device objects are of type C<Device::Blkid::E2fsprogs::Device>.

=item C<dev_iterate_begin($cache)>

Returns a device iterator object on the specified device cache, undef on failure. Device iterator onjects
are of type C<Device::Blkid::E2fsprogs::DevIter>.

=item C<dev_set_search($dev_iter, $type, $value)>

This function places a search filter on the specified device iterator based upon the criteria passed
in on the final two arguments of the function. After this function has been called on the given iterator
with a type and value argument, the iterator will only return onjects which match the specified criteria.
Please note, the $type argument can also contain any valid blkid entity category, such as a LABEL or UUID
tag for example.

  # Set iterator to filter and match only on ext4 file systems
  dev_set_search($dev_iter, 'TYPE', 'ext4');

On success, returns a copy of the device iterator object or undef on fail.

=item C<dev_next($dev_iter, $device)>

Returns the next device object in the iteration. Check for undef as an end of list sentinal.

=item C<dev_iterate_end($dev_iter)>

Frees the allocated iterator object from memory, although this is redundant; simply undef'ing the object to
remove references to it or allowing it to go out of scope will also free the memory by design. (May be removed
in a future version).

=item C<devno_to_devname($devno)>

Given a device number, returns the associated device name (e.g., /dev/sda1) or undef if no match found.

=item C<probe_all($cache)>

Given a valid cache object, probes the underlying block devices on the system and updates the cache where
necessary.  Returns an undef on fail.

=item C<probe_all_new($cache)>

Given a valid cache object, probes the system for any newly added devices, updating the cache where necessary.
Returns an undef on fail.

=item C<get_dev($cache, $devname, $flags)>

Returns a device object based upon the input criteria. Please refer to the constants sections to see what flags
may be passed in to determine results. An undef is returned in the event of any problems.

=item C<get_dev_size(int $fd)>

Given a device object passed in over a file descriptor, this function returns the size of that device. Please note,
this is a file descriptor and NOT a Perl file handle! (thanks for the note Friedrich).  Please see POSIX in perldoc
for further details.

=item C<known_fstype($fstype)>

Determines if a file system type is known to libblkid. If the file system is known, it returns the input argument string,
otherwise undef is returned.

=item C<verify($cache, $device)>

Attempts to verify that the device object is a valid blkid device. Returns the instance of the valid device onject on success,
otherwise undef is returned to indicate failure.

=item C<get_tag_value($cache, $tagname, $devname)>

Given a valid $cache object, $tagname and $devname, this function returns the value to which the tag refers.

  # Given the following and assuming them valid on this system
  my $tagname = 'LABEL';
  my $devname = '/dev/sda4';

  # The following say might print '/boot'
  my $tag_value = get_tag_value($cache, $tagname, $devname);
  say $tag_value;

=item C<get_devname($cache, $token, $value)>

Similar to the last call, given a valid $cache object and token and value parameters, will return the devname of
the block device.

=item C<tag_iterate_begin($device)>

Returns a tag iterater object on a valid device type, undef on fail.

=item C<tag_next($tag_iter)>

Returns a has reference containing the next available tag pairing from the list (e.g. { type => "UUID", value => '0x000000' }.
Undef is returned on failure.

=item C<tag_iterate_end($tag_iter)>

Frees the memory allocated for the tag iterator object. This is redundant as the memory can be freed by removing references to
the object, undef'ing it or allowing it to leave scope.

=item C<dev_has_tag($device, $type, $value)>

Determines if the given device contains the specified tag. If it does, the device instance is returned, otherwise undef.

=item C<find_dev_with_tag(cache, type, value)>

Given a tag type and value, crawls the blkid cache for a match and returns an instance of the device if found, otherwise undef.

=item C<parse_tag_string()>

TBD

=item C<parse_version_string($ver_string)>

Given a version string, returns an integer like representation of the string. I am not sure what a fail state is on this; it would
happily process decimal dotted formatted version string quite happily, only breaking when I over ran the bounds of the underlying
integer type. I will investigate this further.

=item C<get_library_version()>

TBD - Will return a hash containing both a version and a date string for the libblkid build on the system.

=back

=head1 SEE ALSO

L<E2fsprogs project home page|http://e2fsprogs.sourceforge.net/>

L<blkid(8)>

L<PerlXS|http://perldoc.perl.org/perlxs.html>

L<Device::Blkid> - This is probably what you want, unless you have very specific needs or constraints.

This package project is also hosted on Github at
git://github.com/raymroz/Device--Blkid--E2fsprogs.git

=head1 AUTHOR

Raymond Mroz, E<lt>mroz@cpan.org<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Raymond Mroz

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.1 or,
at your option, any later version of Perl 5 you may have available.

=head1 TODO

For starters, after I get the initial kinks ironed out, I will be stripping much of the
C preprocessor stuff and assertions. I tend to go heavy on that sort of thing during early
build and test but I will get much of it cleaned up in the week or two ahead.

About half way through my implementation, it dawned on me that I would like to bring this
interface an even more 'Perlish' feel; I have some ideas about dropping some of these
calls and combining others to achieve this end.

I will be adding support in for older versions of the e2fsprogs-based package by way of
some C preprocessor magic to exclude/include various calls as they were supported
and by passing in version arguments to Makefile.PL to generate the proper version
compliant interface.

Test scripts, test scripts, test scripts.

=head1 CREDITS

First and foremost I would like to thank Friedrick for his L<Device::Blkid>. Your POD
really proved helpful at times as the documentation for libblkid can be rather scant and
your code was in places inspirational (even though I went in the C direction and you in
the XSUB one :).  Thanks!

Secondly, I would like to thank Larry McInnis for the extra hardware on which I could
code and test this. I currently have most of my hardware tied up for other purposes so
writing a Perl interface to an e2fsprogs build of libblkid was proving a hassle on the
latest and great Debian offering. With a laptop he ponied up, I had Fedora Core 10 on
it in no times and was off from there.

=head1 BUGS

What's a bug? :)

No known bugs at this time. That said, this module is largely written in C and does contain
a number of memory allocations. While these allocations are done inside of libblkid itself,
I do make every attempt to free the memory explicitly when I am done with it. That said, leaks
are possible. Please report any issues as is detailed above.


=cut
