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
  
  unless(-e File::Spec->catfile('xs', 'func.h'))
  {
  
    $alien ||= Alien::Libarchive->new;
  
    open(my $fh, '<', File::Spec->catfile('inc', 'symbols.txt'));
    my @symbols = <$fh>;
    close $fh;
    chomp @symbols;
    
    push @symbols, map { "archive_read_support_compression_$_" } qw( all bzip2 compress gzip lzip lzma none program program_signature rpm uu xz );
    push @symbols, map { "archive_write_set_compression_$_" } qw( bzip2 compress gzip lzip lzma none program xz );
    push @symbols, 'archive_write_set_format_old_tar';
  
    open($fh, '>', File::Spec->catfile('xs', 'func.h.tmp'));
    print $fh "#ifndef FUNC_H\n";
    print $fh "#define FUNC_H\n\n";

    # TODO: can probably scan the dll on Windows 
    # for the symbols, which will save time
    if($alien->install_type eq 'system' || $^O eq 'MSWin32')
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
    rename(File::Spec->catfile('xs', 'func.h.tmp'), File::Spec->catfile('xs', 'func.h'));
  }
  
  $self->SUPER::ACTION_build(@_);
}

sub ACTION_clean
{
  my $self = shift;
  unlink(File::Spec->catfile('xs', 'func.h.tmp'), File::Spec->catfile('xs', 'func.h'));
  $self->SUPER::ACTION_clean(@_);
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
  if($symbol =~ /^archive_write_set_format_/ && $symbol !~ /^archive_write_set_format_(program|by_name)/)
  {
    # TODO: this test should maybe happen regardless of shared/system
    print $fh "{\n";
    print $fh "  struct archive *a = archive_write_new();\n";
    print $fh "  $symbol(a);\n";
    print $fh "  archive_write_free(a);\n";
    print $fh "}\n";
  }
  else
  {
    print $fh "{ void *ptr = (void*)$symbol; }\n";
    close $fh;
  }
  
  my $cflags = $alien->cflags;
  my $libs   = $alien->libs;

  if(eval q{ use Capture::Tiny; 1 })
  {
    my $error;
    my $obj;
    Capture::Tiny::capture_merged(sub {
      eval { $obj = $self->compile_c($fn) };
      $error = $@;
    });
    my $status = $error eq '';

    if($status && $symbol =~ /^archive_write_set_format_(.*)$/)
    {
      if($1 !~ /^(program|by_name)$/)
      {
        $alien ||= Alien::Libarchive->new;
        my $exe;
        my $error;
        Capture::Tiny::capture_merged(sub {
          $exe = eval { 
            $self->cbuilder->link_executable(
              objects            => [ $obj ],
              extra_linker_flags => $alien->libs,
            );
          };
          $error = $@;
        });
      
        if($error)
        {
          $status = 0;
        }
        else
        {
          Capture::Tiny::capture_merged(sub {
            system $exe, 'argument';
            $status = $? == 0;
          });
        }
      }
    }
    
    printf "%-50s %s\n", $symbol, ($status ? 'yes' : 'no');

    return $status;
  }
  else
  {
    eval { $self->compile_c($fn) };
    return $@ eq '';
  }
}

1;
