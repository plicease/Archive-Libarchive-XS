package Archive::Libarchive::XS::ModuleBuild;

use strict;
use warnings;
use base qw( Module::Build );
use Alien::Libarchive;
use File::Spec;
use DynaLoader;
use File::Temp qw( tempdir );
use File::Spec;

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
  
  $alien ||= Alien::Libarchive->new;

  open(my $fh, '<', File::Spec->catfile('inc', 'symbols.txt'));
  my @symbols = <$fh>;
  close $fh;
  chomp @symbols;
  
  open($fh, '>', File::Spec->catfile('xs', 'func.h'));
  print $fh "#ifndef FUNC_H\n";
  print $fh "#define FUNC_H\n\n";

  if($alien->install_type('system'))
  {
    foreach my $symbol (@symbols)
    {
      print $fh "#define HAS_$symbol 1\n"
        if $self->_test_compile_symbol($symbol);
    }
  }
  else
  {
    foreach my $symbol (@symbols)
    {
      print $fh "#define HAS_$symbol 1\n"
        if DynaLoader::dl_find_symbol_anywhere($symbol);
    }
  }
  
  print $fh "\n#endif\n";
  close $fh;
  
  $self->SUPER::ACTION_build(@_);
}

my $dir;
my $count = 0;

sub _test_compile_symbol
{
  my($self, $symbol) = @_;
  
  $dir = tempdir( CLEANUP => 1 ) unless $dir;
  
  my $fn = File::Spec->catfile($dir, "foo$count.c");
  $count++;
  open my $fh, '>', $fn;
  print $fh "#include <archive.h>\n";
  print $fh "#include <archive_entry.h>\n";
  print $fh "int main(int argc, char *argv)\n";
  print $fh "{ void *ptr = (void*)$symbol; }\n";
  close $fh;
  
  my $cflags = $alien->cflags;
  my $libs   = $alien->libs;
  
  #system "gcc $cflags $fn $libs";
  #return ! $?;
  
  eval { $self->compile_c($fn) };
  return $@ eq '';
}

1;
