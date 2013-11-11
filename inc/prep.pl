use strict;
use warnings;
use v5.10;
use Alien::Libarchive;
use Path::Class qw( file dir );

my $alien = Alien::Libarchive->new;
my @macros = grep { $_ !~ /H_INCLUDED$/ } $alien->_macro_list;

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


do { # xs
  my $file = file(__FILE__)->parent->parent->file(qw( lib Archive Libarchive XS.pm ))->absolute;
  my @perl = $file->slurp;

  my $buffer;

  $buffer .= shift @perl while @perl > 0 && $perl[0] !~ /^=head1 CONSTANTS/;
  $buffer .= shift @perl while @perl > 0 && $perl[0] !~ /^=over 4/;
  shift @perl while @perl > 0 && $perl[0] !~ /^=cut/;

  $buffer .= "=over 4\n\n";
  foreach my $macro (@macros)
  {
    $buffer .= "=item $macro\n\n";
  }
  $buffer .= "=back\n\n";
  
  $buffer .= shift @perl while @perl > 0 && $perl[0] !~ /CONSTANT AUTOGEN BEGIN/;
  $buffer .= "# CONSTANT AUTOGEN BEGIN\nqw(\n";
  shift @perl while @perl > 0 && $perl[0] !~ /CONSTANT AUTOGEN END/;
  
  foreach my $macro (@macros)
  {
    $buffer .= "$macro\n";
  }
  
  $buffer .= ")\n";
  $buffer .= join '', @perl;
  
  $file->spew($buffer);
};

