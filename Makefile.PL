# Makefile.PL - Device::Blkid::E2fsprogs
#
# Ray Mroz - mroz@cpan.org
# Copyright (C) 2011

use lib qw(inc);
use Devel::CheckLib qw/ :funcs :cflag_defs /
  ;    # See legend below for list of constants imported

# This next section is for Devel::CheckLib. I have hax0r3d this a tad. As well as checking
# for the existance of the blkid library, I am also going to make a call on the lib to get
# version data which is used to set a DEFINE for the C preprocessor. This will provide for
# dynamic version detection of libblkid in target systems. Dynamic version detection is
# optional and can be bypassed during the initial configuration when running this script.

# Version history of e2fsprogs libblkid
#
# Version legend
#
# Versions > 2.xx.x ( > 2000 ) is util-linux-ng (use the Device::Blkid library instead)
# Version 1.40 (140) - 25 API calls
# Version 1.38 (138) - 24 API calls
# Version 1.36 (136) - 21 API calls
# Version 1.34 (134) - 18 API calls - Dynamic version configuration is NOT supported for this version
# Version 1.33 (133) - 17 API calls - Dynamic version configuration is NOT supported for this version

# Note: The blkid_get_library_version() call modifies both its parameters (C strings) and
# returns an 'integerized' version based upon the real, string-based version. We use this
# below to determine and return a version type. All versions above 1.40.1 return a 4 digit
# integer and since the return type is only a single WORD in width, we need to drop the
# last digit from versions > 2.00.0. Also note, the get version API calls first appeared
# in version 1.36 of libblkid so versions older than this are not currently supported. See
# DEFINE argument of WriteMakefile below.

# Constants imported from Devel::Checklib as 'cflag_defs' representing CFLAG defines which
# are passed as C compiler args when building the module.
# API_DEF_133 => qq/-D__API_1_33/,
# API_DEF_136 => qq/-D__API_1_33 -D__API_1_36/,
# API_DEF_138 => qq/-D__API_1_33 -D__API_1_36 -D__API_1_38/,
# API_DEF_140 => qq/-D__API_1_33 -D__API_1_36 -D__API_1_38 -D__API_1_40/,

my $output = qq(
        Running Makefile.PL to perform package configuration.
        Would you like to try dynamic libblkid version detection and configuration?

        Y/y or N/n: );
print $output;
my $line;
chomp( $line = <STDIN> );
$line = lc($line);

my $api_define;

# User has opted for dynamic library version detection and configuration
if ( $line eq 'y' ) {
    $api_define = check_blkid_version_or_exit(
        function => '
        const char *vers = NULL;
        const char *date = NULL;
        int vernum = 0;
        vernum = blkid_get_library_version(&vers, &date);
        if (vernum >= 2000)
            return(200); /* Childs return value only 1 byte wide */
        if (vernum >= 140)
            return(140);
        if (vernum >= 138)
            return(138);
        if (vernum >= 136)
            return(136); 
        return (-1); /* Default catch, something is borked */
        ',
        incpath => '/usr/include/blkid',
        lib     => 'blkid',
        header  => [ 'blkid.h', 'stdio.h', 'stdlib.h' ],
        blkid   => 1,
    );
}

# User has opted for manual selection of libblkid version
elsif ( $line eq 'n' ) {

    $output = qq[
        The default is to build a v1.33 compliant interface as it will work with all e2fsprogs-based
        versions of libblkid. Keep in mind that attempting to build a version target which is more
        recent than the version which you have installed will fail with linker errors. If you are not
        entirely certain which version which you have installed, accepting the default here (a 'Y/y'
        selection) is safest, however you may wish to try the dynamic version detection which should
        accurately determine versions 1.36 and newer.

        If the default v1.33 build target is acceptable to you, please answer 'Y/y', otherwise select
        one of the following version bundles from the list, or 'Q/q' to quit:

        1. v1.36 (compliant with libblkid versions 1.36-1.37)
        2. v1.38 (compliant with libblkid versions 1.38-1.39)
        3. v1.40 (compliant with all libblkid versions better than 1.40)

        Enter selection (Y/y for default or option 1, 2, 3): ];
    print $output;
    chomp( $line = <STDIN> );
    $line = lc($line);

    $api_define = API_DEF_133 if ( $line eq 'y' );
    $api_define = API_DEF_136 if ( $line == 1 );
    $api_define = API_DEF_138 if ( $line == 2 );
    $api_define = API_DEF_140 if ( $line == 3 );
    eval {
        print("\tExiting, no Makefile has been built.\n");
        exit;
    } if ( $line eq 'q' );

    unless ( defined($api_define) ) {
        warn("\tInvalid selection, exiting\n\n");
        exit;
    }

    check_lib_or_exit(
        incpath => '/usr/include/blkid',
        lib     => 'blkid',
        header  => [ 'blkid.h', 'stdio.h', 'stdlib.h' ],
    );
}
else {
    warn("\tInvalid selection, exiting.\n\n");
    exit;
}

use 5.008000;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME         => 'Device::Blkid::E2fsprogs',
    VERSION_FROM => 'lib/Device/Blkid/E2fsprogs.pm',
    PREREQ_PM    => {
        'Exporter'      => '0',
        'Test::More'    => '0',
        'Test::Builder' => '0',
    },
    (
        $] >= 5.005
        ? (
            ABSTRACT_FROM => 'lib/Device/Blkid/E2fsprogs.pm',
            AUTHOR        => 'Raymond Mroz <mroz@cpan.org>'
          )
        : ()
    ),
    LIBS          => ['-lblkid'],
    NEEDS_LINKING => 1,

    # To create a debug build, please add '-D__DEBUG' to the DEFINE
    # line below, as here:      DEFINE  =>  '-D__DEBUG', or uncomment
    # the line below.
    # DEFINE => qq/$api_define -D__DEBUG/,
    # Make sure to leave the '$api_define' and keep the string double
    # quoted to support dynamic library version detection and build targets
    # Note: To disable version-based build targets, remove '$api_define'
    # below and replace with any custom DEFINE directives which you require
    DEFINE    => "$api_define",
    INC       => '-I.',
    LICENSE   => 'perl',
    EXE_FILES => [],
    dist      => { COMPRESS => 'gzip -9f', SUFFIX => 'gz' },
    clean => { FILES => 'Device-Blkid-E2fsprogs-*' },
);
