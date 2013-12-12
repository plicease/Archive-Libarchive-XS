use strict;
use warnings;
use Test::More tests => 3;
use Archive::Libarchive::XS qw( :all );

# translated from test_archive_match_owner.c

my $r;

subtest uid => sub {
  plan tests => 21;
  my $m = archive_match_new();
  ok $m, 'archive_match_new';

  my $e = archive_entry_new();
  ok $e, 'archive_entry_new';
  
  $r = archive_match_include_uid($m, 1000);
  is $r, ARCHIVE_OK, 'archive_match_include_uid 1000';

  $r = archive_match_include_uid($m, 1002);
  is $r, ARCHIVE_OK, 'archive_match_include_uid 1002';

  $r = archive_entry_set_uid($e, 0);
  is $r, ARCHIVE_OK, 'archive_entry_set_uid 0';  
  ok archive_match_owner_excluded($m, $e), 'archive_match_owner_excluded (0)';
  ok archive_match_excluded($m,$e),        'archive_match_excluded (0)';

  $r = archive_entry_set_uid($e, 1000);
  is $r, ARCHIVE_OK, 'archive_entry_set_uid 1000';
  ok !archive_match_owner_excluded($m, $e), 'archive_match_owner_excluded (1000)';
  ok !archive_match_excluded($m,$e),        'archive_match_excluded (1000)';

  $r = archive_entry_set_uid($e, 1001);
  is $r, ARCHIVE_OK, 'archive_entry_set_uid 1001';
  ok archive_match_owner_excluded($m, $e), 'archive_match_owner_excluded (1001)';
  ok archive_match_excluded($m,$e),        'archive_match_excluded (1001)';

  $r = archive_entry_set_uid($e, 1002);
  is $r, ARCHIVE_OK, 'archive_entry_set_uid 1002';
  ok !archive_match_owner_excluded($m, $e), 'archive_match_owner_excluded (1002)';
  ok !archive_match_excluded($m,$e),        'archive_match_excluded (1002)';

  $r = archive_entry_set_uid($e, 1003);
  is $r, ARCHIVE_OK, 'archive_entry_set_uid 1002';
  ok archive_match_owner_excluded($m, $e), 'archive_match_owner_excluded (1003)';
  ok archive_match_excluded($m,$e),        'archive_match_excluded (1003)';
  
  $r = archive_match_free($m);
  is $r, ARCHIVE_OK, 'archive_match_free';

  $r = archive_entry_free($e);
  is $r, ARCHIVE_OK, 'archive_entry_free';
};

subtest gid => sub {
  plan tests => 21;
  my $m = archive_match_new();
  ok $m, 'archive_match_new';

  my $e = archive_entry_new();
  ok $e, 'archive_entry_new';
  
  $r = archive_match_include_gid($m, 1000);
  is $r, ARCHIVE_OK, 'archive_match_include_gid 1000';

  $r = archive_match_include_gid($m, 1002);
  is $r, ARCHIVE_OK, 'archive_match_include_gid 1002';

  $r = archive_entry_set_gid($e, 0);
  is $r, ARCHIVE_OK, 'archive_entry_set_gid 0';  
  ok archive_match_owner_excluded($m, $e), 'archive_match_owner_excluded (0)';
  ok archive_match_excluded($m,$e),        'archive_match_excluded (0)';

  $r = archive_entry_set_gid($e, 1000);
  is $r, ARCHIVE_OK, 'archive_entry_set_gid 1000';
  ok !archive_match_owner_excluded($m, $e), 'archive_match_owner_excluded (1000)';
  ok !archive_match_excluded($m,$e),        'archive_match_excluded (1000)';

  $r = archive_entry_set_gid($e, 1001);
  is $r, ARCHIVE_OK, 'archive_entry_set_gid 1001';
  ok archive_match_owner_excluded($m, $e), 'archive_match_owner_excluded (1001)';
  ok archive_match_excluded($m,$e),        'archive_match_excluded (1001)';

  $r = archive_entry_set_gid($e, 1002);
  is $r, ARCHIVE_OK, 'archive_entry_set_gid 1002';
  ok !archive_match_owner_excluded($m, $e), 'archive_match_owner_excluded (1002)';
  ok !archive_match_excluded($m,$e),        'archive_match_excluded (1002)';

  $r = archive_entry_set_gid($e, 1003);
  is $r, ARCHIVE_OK, 'archive_entry_set_gid 1002';
  ok archive_match_owner_excluded($m, $e), 'archive_match_owner_excluded (1003)';
  ok archive_match_excluded($m,$e),        'archive_match_excluded (1003)';
  
  $r = archive_match_free($m);
  is $r, ARCHIVE_OK, 'archive_match_free';

  $r = archive_entry_free($e);
  is $r, ARCHIVE_OK, 'archive_entry_free';
};

subtest uname => sub {
  my $m = archive_match_new();
  ok $m, 'archive_match_new';

  my $e = archive_entry_new();
  ok $e, 'archive_entry_new';

  $r = archive_match_include_uname($m, "foo");
  is $r, ARCHIVE_OK, 'archive_match_include_uname foo';

  $r = archive_match_include_uname($m, "bar");
  is $r, ARCHIVE_OK, 'archive_match_include_uname bar';

  #$r = archive_entry_set_uname($e, "unknown");
  #is $r, ARCHIVE_OK, 'archive_entry_set_uname unknown';

  $r = archive_match_free($m);
  is $r, ARCHIVE_OK, 'archive_match_free';
  
  $r = archive_entry_free($e);
  is $r, ARCHIVE_OK, 'archive_entry_free';
};

__END__
        archive_entry_copy_uname(ae, "unknown");
        failure("User 'unknown' should be excluded");
        assertEqualInt(1, archive_match_owner_excluded(m, ae));
        assertEqualInt(1, archive_match_excluded(m, ae));
        archive_entry_copy_uname(ae, "foo");
        failure("User 'foo' should not be excluded");
        assertEqualInt(0, archive_match_owner_excluded(m, ae));
        assertEqualInt(0, archive_match_excluded(m, ae));
        archive_entry_copy_uname(ae, "foo1");
        failure("User 'foo1' should be excluded");
        assertEqualInt(1, archive_match_owner_excluded(m, ae));
        assertEqualInt(1, archive_match_excluded(m, ae));
        archive_entry_copy_uname(ae, "bar");
        failure("User 'bar' should not be excluded");
        assertEqualInt(0, archive_match_owner_excluded(m, ae));
        assertEqualInt(0, archive_match_excluded(m, ae));
        archive_entry_copy_uname(ae, "bar1");
        failure("User 'bar1' should be excluded");
        assertEqualInt(1, archive_match_owner_excluded(m, ae));
        assertEqualInt(1, archive_match_excluded(m, ae));
