package inc::ModuleBuild;

use Moose;
use namespace::autoclean;
use v5.10;

with 'Dist::Zilla::Role::InstallTool';

sub setup_installer
{
  my($self) = @_;

  my($makefile) = grep { $_->name eq 'Build.PL' } @{ $self->zilla->files };
  
  my $content = $makefile->content;
  
  state $checks;
  unless($checks)
  {
    $checks = do { local $/; <DATA> };
  }
  
  if($content =~ s{(my \$build =)}{$checks$1}m)
  {
    $makefile->content($content);
    $self->zilla->log("Modified Build.PL");
  }
  else
  {
    $self->zilla->log_fatal("unable to update Build.PL");
  }
}

1;

__DATA__

use Alien::Libarchive;
my $alien = Alien::Libarchive->new;
$module_build_args{extra_compiler_flags} = $alien->cflags;
$module_build_args{extra_linker_flags}   = $alien->libs;
$module_build_args{c_source}             = 'xs';
