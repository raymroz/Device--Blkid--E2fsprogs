use lib qw(inc);
use Devel::CheckLib;

# This next section is for Devel::CheckLib. I am taking this further. As well as checking for the existance of the blkid
# library, I am also going to make a call on the lib to get version data which is used to set a DEFINE for the C
# preprocessor. This will provide for multiple version support.

# Version history of e2fsprogs libblkid
#
# Version legend
#
# Versions > 2.xx.x ( > 2000 ) is util-linux-ng (use the Device::Blkid library instead)
# Version 1.40 (140) - 25 API calls
# Version 1.38 (138) - 24 API calls
# Version 1.36 (136) - 21 API calls
# Version 1.34 (134) - 18 API calls - NOT supported at this time, no calls return a library version
# Version 1.33 (133) - 17 API calls - NOT supported at this time, no calls return a library version

my $API_DEFINE;

$API_DEFINE = check_lib_version_or_exit (
    function => '
        const char *vers = NULL;
        const char *date = NULL;
        int vernum = 0;
        vernum = blkid_get_library_version(&vers, &date);
        if (vernum >= 2000)
            return(200); /* Can only return 1 byte */
        if (vernum >= 140)
            return(140);
        if (vernum >= 138)
            return(138);
        if (vernum >= 136)
            return(136); 
        return (-1);
        ',
    incpath => '/usr/include/blkid',
    lib     => 'blkid',
    header  => [ 'blkid.h', 'stdio.h', 'stdlib.h', 'string.h' ],
);

use 5.008000;
use ExtUtils::MakeMaker;


# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
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
    # DEFINE => '-D__DEBUG',
    DEFINE => $API_DEFINE,
    INC    => '-I.',

    # Un-comment this if you add C files to link with later:
    # OBJECT            => '$(O_FILES)', # link all the C files too

    EXE_FILES => [],
    dist      => { COMPRESS => 'gzip -9f', SUFFIX => 'gz' },
    clean => { FILES => 'Device-Blkid-E2fsprogs-*' },
);
