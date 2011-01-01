use 5.010001;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Blkid',
    VERSION_FROM      => 'lib/Blkid.pm', # finds $VERSION
    PREREQ_PM         => { 'Data::Dump' => '0' }, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Blkid.pm', # retrieve abstract from module
       AUTHOR         => 'Raymond Mroz <rmroz@cpan.org>') : ()),
    LIBS              => ['-lblkid'], # e.g., '-lm'
    DEFINE            => '-D__DEBUG', # e.g., '-DHAVE_SOMETHING'
    INC               => '-I.', # e.g., '-I. -I/usr/include/other'
	# Un-comment this if you add C files to link with later:
    # OBJECT            => '$(O_FILES)', # link all the C files too
);
