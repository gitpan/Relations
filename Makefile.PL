use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
  'NAME'         => 'Relations',
  'VERSION_FROM' => 'Relations.pm', 
  ($] ge '5.005') ? 
  (
    'AUTHOR'   => 'George A. Fitch III (aka Gaffer), gaf3@gaf3.com',
    'ABSTRACT' => 'DBI/DBD::mysql functions to ease development',
  ) : (),
  'PREREQ_PM' => 
  { 
    'DBI'        => 1.13,
    'DBD::mysql' => 1.18
  },
  'PM' => {
     'Relations.pm' => '$(INST_LIBDIR)/Relations.pm'
  }
);