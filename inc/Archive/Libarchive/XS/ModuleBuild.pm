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

  my $self = $class->SUPER::new(%args);
  
  $self->add_to_cleanup(
    File::Spec->catfile('xs', 'func.h.tmp'),
    File::Spec->catfile('xs', 'func.h'),
    '*.core',
    'test-*',
  );
  
  $self;
}

sub ACTION_build_prep
{
  my($self) = shift;

  return if -e File::Spec->catfile('xs', 'func.h');
  
  print "creating xs/func.h\n";
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
    foreach my $symbol (sort @symbols)
    {
      if($symbol =~ /^archive_write_set_format_/ && $symbol !~ /^archive_write_set_format_(program|by_name)/)
      {
        print $fh "#define HAS_$symbol 1\n"
          if $self->_test_write_format($symbol);
      }
      else
      {
        print $fh "#define HAS_$symbol 1\n"
          if $self->_test_symbol($symbol);
      }
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
  rename(File::Spec->catfile('xs', 'func.h.tmp'), File::Spec->catfile('xs', 'func.h')) || die "unable to rename $!";
}

sub ACTION_build
{
  my $self = shift;
  $self->depends_on('build_prep');
  $self->SUPER::ACTION_build(@_);
}

sub ACTION_test
{
  # doesn't seem like this should be necessary, but without
  # this, it doesn't call my ACTION_build
  my $self = shift;
  $self->depends_on('build');
  $self->SUPER::ACTION_test(@_);
}

sub ACTION_install
{
  # doesn't seem like this should be necessary, but without
  # this, it doesn't call my ACTION_build
  my $self = shift;
  $self->depends_on('build');
  $self->SUPER::ACTION_install(@_);
}

my $dir;
my $count = 0;
my $cc;

if(eval qq{ use Capture::Tiny; 1 })
{
  eval qq{
    sub _capture_tiny {
      my \$code = shift;
      Capture::Tiny::capture_merged(sub { \$code->()});
    }
  };
  die $@ if $@;
}
else
{
  eval qq{
    sub _capture_tiny {
      \$_[0]->();
    }
  };
  die $@ if $@;
}

sub _cc
{
  require ExtUtils::CChecker;
  $alien ||= Alien::Libarchive->new;

  unless(defined $cc)
  {
    require Text::ParseWords;
    $cc = ExtUtils::CChecker->new;
    $cc->push_extra_compiler_flags(Text::ParseWords::shellwords($alien->cflags)) if $alien->cflags !~ /^\s*$/;
    $cc->push_extra_linker_flags(Text::ParseWords::shellwords($alien->libs))     if $alien->libs   !~ /^\s*$/;
  }
}

sub _test_write_format
{
  my($self, $symbol) = @_;
  _cc();
  my $ok;
  _capture_tiny(sub { $ok = $cc->try_compile_run(source => <<EOF1) });
#include <archive.h>
#include <archive_entry.h>
int main(int argc, char **argv)
{
  struct archive *a = archive_write_new();
  $symbol(a);
  archive_write_free(a);
  return 0;
}
EOF1
  printf "%-50s %s\n", $symbol, ($ok ? 'yes' : 'no');
  return $ok;
}

sub _test_symbol
{
  my($self, $symbol) = @_;
  _cc();
  my $ok;
  _capture_tiny(sub { $ok = $cc->try_compile_run(source => <<EOF2) });
#include <stdio.h>
#include <archive.h>
#include <archive_entry.h>
int main(int argc, char **argv)
{
  void *ptr = (void*)$symbol;
  printf("%p\\n", ptr);
  return 0;
}
EOF2

  printf "%-50s %s\n", $symbol, ($ok ? 'yes' : 'no');
  return $ok;
}

1;
