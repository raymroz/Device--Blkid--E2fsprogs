package Device::Blkid::E2fsprogs;

our $VERSION = '0.18';

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

Device::Blkid::E2fsprogs - Perl interface to e2fsprogs-based libblkid (v1.33 - v1.41.4)

=head1 SYNOPSIS

  use Device::Blkid::E2fsprogs qw/ :funcs /;

  # Get a cache object from libblkid, checking for exception
  my $cache_file = '/etc/blkid/blkid.tab';

  local $@;
  my $cache - eval { get_cache($cache_file) };
  if ($@) {
      # Do something, log or die
      die "Error while obtaining cache file: $@";
  }

  # Get the device associated with a given blkid LABEL
  my $type = 'LABEL';
  my $label = 'SWAP';

  # Using the cache
  my $devname = get_devname($type, $value, $cache);

  # Get a Device::Blkid::E2fsprogs::Device object
  my $device = get_dev($cache, $devname, $flags);

  # Get device iterator, checking for exceptions
  local $@;
  my $dev_iter = eval { dev_iterate_begin($cache) };
  if ($@) {
      # Handle exception
  }

  # And now iterate over list of devices
  if ( dev_next($dev_iter) ) {
      do_something();
  }

  # To explicitly force memory deallocation on an allocated object
  undef $cache; 

=head1 DESCRIPTION

  NOTE: This library only exposes the older e2fsprogs versions of libblkid ( numbered 1.xx.x)
  and not the newer and preferred util-linux-ng versions ( v2.15 or better ). In almost
  every case you would be advised to use Bastian Friedrich's util-linux-ng based Device::Blkid
  module as the newer lib interface is (mostly) backward compatible with the old one. This
  module would prove useful in any situation where for any reason you are limited on your
  systems to a 1.xx.x libblkid version which is a part of the e2fsprogs package. Incidentally,
  libblkid version numbering is based upon the version of either util-linux-ng or e2fsprogs of
  which it was a part and as such, e2fsprogs based versions of the library were all numbered
  v1.xx.x whereas util-linux-ng versions are numbered as v2.15 or better which was the version
  of util-linux-ng in which it was added to that package. So just to be clear, when in doubt
  you are advised to grab Bastian's newer util-linux-ng based libblkid interface module unless
  you have some specific reason as to why you can't, perhaps something similar to what led me
  to write this version.

  This version has been implemented somewhat differently than Bastian's util-linux-ng build
  of the library. He opted to keep much of his logic and processing in XSUB, mine is done
  mostly in C; I have only used XSUB for my straight glue, everything else I kept in C. This is
  not to be taken as any opinion of statement on PerlXS/XSUB, its merely a reflection of my own
  background and tastes.

This package provides a Perl interface to the e2fsprogs-based versions of libblkid. It does not
support the larger and more robust API which has been added and integrated into the libblkid
library since its inclusion in the util-linux-ng package. That said, the libblkid which now
ships with util-linux-ng is reportedly backward compatible with client code dependant upon the
older, original library which would mean that this module should work with it, albeit with the
more limited selection of API calls. Please see the preceding note for additional details.

Libblkid provides a means of identifying block devices as to their content (such as filesystems)
as well as allowing for the extraction of additional information such as filesystem labels,
volume labels, serial numbers, device numbers, unique identifiers, etc. The libblkid library
maintains a mapping of all of this composite information and maintains its association with
a given block device on the system. Libblkid is becoming more commonly seen in modern linux
distributions in places such as configuration files and other such places where hard coded
device names were once used.

In addition to providing for low level probing of block devices for this information, the
library maintains an on disk cache file of this data. It is by way of the cache file that
unpriviledged users are able to access this information via a variety of library calls. Use of
the cache file as opposed to direct, low level probing of the hardware is recommended whenever
possible and feasible.

Recognizing that this is a Perl module, I have tried to provide a more 'Perlish' interface
where possible rather than merely map Perl subs to C functions. Most library functions return
an undef on failure and a number of calls return hash types.

Please read the README file in the package archive for instructions should you encounter any
problems while using this software package, as well as for instructions on building a debug
version.

It is worth noting that between versions 1.33 and 1.41.4, the entire period which libblkid
was shipping as a part of the e2fsprogs package, the number of calls present in the API
expanded from the 17 in the original release of the library back in 2003 to 24 when it was
migrated over to the util-linux-ng package in early 2009. This module supports all 24 calls
from the most recent iteration of this run. I will, in an upcoming version of this module,
provide a means for configuring this package for a target release of libblkid by way of
passing arguments to Makefile.PL, but for now it supports the entire breadth of calls.

=head2 INSTALLATION NOTES

This package has made use of a customized Devel::CheckLib module and Makefile.PL in an attempt
to detect the version of libblkid currently installed on the target system and to then generate
a PerlXS interface which directly targets and matches the API interface of that libblkid
version. This process is expected to work on all versions of libblkid later than v1.35.
Should you have any problems with this process, evident either in running the Makefile.PL
or in running make only its resulting Makefile, please see the Makefile.PL as well as the
E2fsprogs.xs file to troubleshoot. If you wish to report any problems with this version
detection, please include any output from their installation process as well as a copy of
your /usr/include/blkid/blkid.h file.

=head2 DEPENDENCIES

L<E2fsprogs v1.33-v1.41.4|http://e2fsprogs.sourceforge.net/>

In order to install this package on systems running a version of libblkid older than version 1.36,
you will be required to manually edit the Makefile.PL, adding the proper define CFLAG for gcc as
well as determine which function calls are present in the API exposed by the version of your
particular libblkid and either comment out or remove them from the E2fsprogs.xs file.  Keep in
mind that the libblkid funtions appear in two seperate sections of that file; in the top half,
which is the C language section as well as the bottom section, the Perl XSUB section.


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

Write any changes to the blkid cache file and explicitly frees associated resources. C<put_cache($cache)>
should be called after you have been doing any work with a cache object.

=item C<get_cache($filename)>

Given a path to a cache file, return a blkid cache object reference. This reference is of type
C<Device::Blkid::E2fsprogs::Cache>. As with other allocated types, throws exception on fail state.

=item C<gc_cache($cache)>

Calling this performs a garbage cleanup on the specified cache by removing all non-existant devices.

=item C<dev_devname($device)>

Given a blkid device object, returns a string representation of the device (e.g., /dev/sda9), undef
if something went wrong. Device objects are of type C<Device::Blkid::E2fsprogs::Device>.

=item C<dev_iterate_begin($cache)>

Returns a device iterator object on the specified device cache. Device iterator onbects are of type
C<Device::Blkid::E2fsprogs::DevIter>. As in the case of other allocated types, throws exception on
fail state.

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

Given a valid cache object, probes the underlying block devices on the system. Returns the cache object
instance on success, undef on fail.

=item C<probe_all_new($cache)>

Given a valid cache object, probes for new block devices on the system. Returns the cache object instance
on success, or undef in fail state.

=item C<get_dev($cache, $devname, $flags)>

Returns a device object based upon the input criteria. Please refer to the constants sections to see what
flags may be passed in to determine behaviour. Device objects are of type C<Device::Blkid::E2fsprogs::Device>.
Throws exception on failure to allocate the device object.

=item C<get_dev_size(int $fd)>

Given a device object passed in over a file descriptor, this function returns the size of that device.
Please note, this is a file descriptor and NOT a Perl file handle.  Please
see POSIX::open in perldoc for further details.

=item C<known_fstype($fstype)>

Determines if a file system type is known to libblkid. If the file system is known, it returns the input
argument string, otherwise undef is returned.

=item C<verify($cache, $device)>

Attempts to verify that the device object is a valid blkid device. Returns the instance of the valid device
object on success, otherwise undef is returned to indicate failure.

=item C<get_tag_value($cache, $tagname, $devname)>

Given a valid $cache object, $tagname and $devname, this function returns the value to which the tag refers.

  # Given the following and assuming them valid on this system
  my $tagname = 'LABEL';
  my $devname = '/dev/sda4';

  # The following say prints '/home' in this example
  my $tag_value = get_tag_value($cache, $tagname, $devname);
  say $tag_value;

=item C<get_devname($cache, $token, $value)>

Similar to the last call, given a valid $cache object and token and value parameters, will return the
devname of the block device.

=item C<tag_iterate_begin($device)>

Returns a tag iterater object on a valid device type, of type C<Device::Blkid::E2fsprogs::TagIter>. Throws
exception on fail state.

=item C<tag_next($tag_iter)>

Returns a hash reference containing the next available tag pairing from the list, or undef is returned
on failure.

  { type => "UUID", value => '83f076b3-7abd-4c32-83df-026e57373900' }

=item C<tag_iterate_end($tag_iter)>

Frees the memory allocated for the tag iterator object. This is redundant as the memory can be freed by
removing references to the object, undef'ing it or allowing it to leave scope.

=item C<dev_has_tag($device, $type, $value)>

Determines if the given device contains the specified tag. If it does, the device instance is returned,
otherwise undef.

=item C<find_dev_with_tag(cache, type, value)>

Given a tag type and value, crawls the blkid cache for a match and returns an instance of the device if
found, undef on failure.

=item C<parse_tag_string()>

Given an tag pair input value in C<type=value> format, returns a hash reference to a hash containing the
two constituent elements as key values. Returns undef in the event of a failure.

  { type => 'LABEL', value => '/boot' }

=item C<parse_version_string($ver_string)>

Given a standard dotted-decimal style version string, returns a raw integer-like representation of the
string, sans decimals.

=item C<get_library_version()>

Returns a hash reference containing the libblkid library version and release date as well as a raw integer
representation of the standard dotted-decimal formatted version string (see L</parse_version_string> above).
Returns undef on failure.

  { version => '1.41.4', date => '27-Jan-2009', raw => '1414' }  

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

This library is free software; you can redistribute it and/or modify it under the same
terms as Perl itself, either Perl version 5.10.1 or, at your option, any later version
of Perl 5 you may have available.

=head1 TODO

After initial testing has been completed, strip much of the C preprocessor trace lines
and assertions.

Add support for additional versions of the e2fsprogs libblkid and provide for a means to
build the library for multiple version targets by passing args in to Makefile.PL.

Consider eliminating redundant calls and implementing an even more 'Perlish' design.

Test scripts, test scripts, test scripts.

=head1 CREDITS

I would like to thank Bastian Friedrich for his L<Device::Blkid>. Given the scant supply
of documentation available on libblkid, especially the older, e2fsprogs-based versions,
his POD proved quite helpful as a source of documentation on the library and saved me a
load of time.  Thanks!

I would also like to thank Larry McInnis for the loan of some hardware on which to develop.
Most everything I have had been tied up and developing on the latest and greatest version
of Debian didn't make much sense.

=head1 BUGS

What's a bug? :)

No known bugs at this time. That said, this module is largely written in C and does contain
a number of memory allocations. While these allocations are done inside of libblkid itself,
I do make every attempt to free the memory explicitly when I am done with it. That said, leaks
are possible. Please report any issues as is detailed above.

=head1 DIRECTION

This is an early release of this module. It and its interface are subject to change at any
time. Please refer to all package documentation before reporting any problems.

=Cut
