use strict;
use warnings;
use v5.10;
use Alien::Libarchive;
use Path::Class qw( file dir );

my $alien = Alien::Libarchive->new;
my @macros = grep { $_ ne 'ARCHIVE_VERSION_STRING' } grep { $_ !~ /H_INCLUDED$/ } $alien->_macro_list;

do { # xs
  my $file = file(__FILE__)->parent->parent->file(qw( lib Archive Libarchive XS.xs ))->absolute;
  my @xs = $file->slurp;

  my $buffer;
  
  $buffer .= shift @xs while @xs > 0 && $xs[0] !~ /CONSTANT AUTOGEN BEGIN/;
  $buffer .= "        /* CONSTANT AUTOGEN BEGIN */\n";
  shift @xs while @xs > 0 && $xs[0] !~ /CONSTANT AUTOGEN END/;
  
  foreach my $macro (@macros)
  {
    next if $macro eq 'ARCHIVE_OK';
    $buffer .= "#ifdef $macro\n";
    $buffer .= "        else if(!strcmp(name, \"$macro\"))\n";
    $buffer .= "          RETVAL = $macro;\n";
    $buffer .= "#endif\n";
                      
  }
  
  $buffer .= join '', @xs;
  
  $file->spew($buffer);
};


do {
  use Pod::Abstract;
  use Mojo::Template;
  use JSON qw( to_json );
  my $mt = Mojo::Template->new;
  
  my $pa = Pod::Abstract->load_file(
    file(__FILE__)->parent->parent->file(qw( lib Archive Libarchive XS.xs ))->stringify
  );
  
  $_->detach for $pa->select('//#cut');
  
  my %functions;
  
  foreach my $pod ($pa->children)
  {
    if($pod->pod =~ /^=head2 ([A-Za-z_]+)/)
    {
      my $name = $1;
      $functions{$name} = $pod->pod;
      $functions{$name} =~ s/\s+$//;
    }
    else
    {
      die "error parsing " .  $pod->text;
    }
  }
  
  $mt->prepend(qq{
    use JSON qw( from_json );
    my \$functions = from_json(q[} . to_json(\%functions) . qq{]);
    my \$constants = from_json(q[} . to_json(\@macros) . qq{] );
  });
  
  my $perl = $mt->render( scalar file(__FILE__)->parent->file(qw( XS.pm.template ))->slurp );

  my $file = file(__FILE__)->parent->parent->file(qw( lib Archive Libarchive XS.pm ))->absolute;
  $file->spew($perl);
};
