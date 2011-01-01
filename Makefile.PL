use 5.010000;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Device::Blkid::E2fsprogs',
    VERSION_FROM      => 'lib/Device/Blkid/E2fsprogs.pm',
    PREREQ_PM         => { 'Data::Dump' => '0' }, 
    ($] >= 5.005 ?     
      (ABSTRACT_FROM  => 'lib/Device/Blkid/E2fsprogs.pm',
       AUTHOR         => 'Raymond Mroz <rmroz@cpan.org>') : ()),
    LIBS              => ['-lblkid'],
    # To create a debug build, please add '-D__DEBUG' to the DEFINE
    # line below, as here:      DEFINE  =>  '-D__DEBUG',
    DEFINE            => '-D__DEBUG',
    INC               => '-I.',
	# Un-comment this if you add C files to link with later:
    # OBJECT            => '$(O_FILES)', # link all the C files too
);
