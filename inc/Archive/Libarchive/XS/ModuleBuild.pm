package Archive::Libarchive::XS::ModuleBuild;

use strict;
use warnings;
use base qw( Module::Build );
use Alien::Libarchive;
use File::Spec;
use DynaLoader;

our $alien;

sub new
{
  my($class, %args) = @_;
  
  $alien ||= Alien::Libarchive->new;

  $args{extra_compiler_flags} = $alien->cflags;
  $args{extra_linker_flags}   = $alien->libs;
  $args{c_source}             = 'xs';

  $class->SUPER::new(%args);
}

sub ACTION_build
{
  my($self) = shift;
  
  open(my $fh, '<', File::Spec->catfile('inc', 'symbols.txt'));
  my @symbols = <$fh>;
  close $fh;
  chomp @symbols;
  
  open($fh, '>', File::Spec->catfile('xs', 'func.h'));
  print $fh "#ifndef FUNC_H\n";
  print $fh "#define FUNC_H\n\n";
  
  foreach my $symbol (@symbols)
  {
    print $fh "#define HAS_$symbol 1\n"
      if DynaLoader::dl_find_symbol_anywhere($symbol);
  }
  
  print $fh "\n#endif\n";
  close $fh;
  
  $self->SUPER::ACTION_build(@_);
}

1;
