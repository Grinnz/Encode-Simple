use strict;
use warnings;
use Test::Without::Module 'Unicode::UTF8';
use Encode::Simple qw(encode decode encode_lax decode_lax
  encode_utf8 decode_utf8 encode_utf8_lax decode_utf8_lax);
use Test::More;

my ($characters, $bytes, $invalid_characters, $invalid_bytes, $replacement_characters, $replacement_bytes,
  $invalid_ascii, $replacement_ascii, $surrogate_characters, $surrogate_bytes);
{
  no warnings 'utf8'; # non-characters in literals

  $characters = "\N{U+2603}\N{U+2764}\N{U+1F366}";
  $bytes = "\xe2\x98\x83\xe2\x9d\xa4\xf0\x9f\x8d\xa6";

  $invalid_characters = "\N{U+D800}\N{U+DFFF}\N{U+110000}\N{U+2603}\N{U+FDD0}\N{U+1FFFF}";
  $invalid_bytes = "\x60\xe2\x98\x83\xf0";

  $replacement_characters = "\N{U+0060}\N{U+2603}\N{U+FFFD}";
  $replacement_bytes = "\xef\xbf\xbd\xef\xbf\xbd\xef\xbf\xbd\xe2\x98\x83\xef\xbf\xbd\xef\xbf\xbd";

  $invalid_ascii = "a\N{U+2603}b\N{U+1F366}";
  $replacement_ascii = 'a?b?';

  $surrogate_characters = "\N{U+D800}\N{U+DFFF}\N{U+2603}";
  $surrogate_bytes = qr/\A....\x26\x03\z/;
}

# valid encode/decode
is encode('UTF-8', my $copy = $characters), $bytes, 'strict encode to UTF-8';
is $characters, $copy, 'original string unmodified';
is decode('UTF-8', $copy = $bytes), $characters, 'strict decode from UTF-8';
is $bytes, $copy, 'original bytes unmodified';

is encode_utf8($copy = $characters), $bytes, 'encode_utf8';
is $characters, $copy, 'original string unmodified';
is decode_utf8($copy = $bytes), $characters, 'decode_utf8';
is $bytes, $copy, 'original bytes unmodified';

# valid lax encode/decode
is encode_lax('UTF-8', $copy = $characters), $bytes, 'lax encode to UTF-8';
is $characters, $copy, 'original string unmodified';
is decode_lax('UTF-8', $copy = $bytes), $characters, 'lax decode from UTF-8';
is $bytes, $copy, 'original bytes unmodified';

is encode_utf8_lax($copy = $characters), $bytes, 'encode_utf8_lax';
is $characters, $copy, 'original string unmodified';
is decode_utf8_lax($copy = $bytes), $characters, 'decode_utf8_lax';
is $bytes, $copy, 'original bytes unmodified';

# invalid encode/decode
ok !eval { encode('UTF-8', $copy = $invalid_characters); 1 }, 'invalid encode errored';
is $invalid_characters, $copy, 'original string unmodified';

ok !eval { encode_utf8($copy = $invalid_characters); 1 }, 'invalid encode_utf8 errored';
is $invalid_characters, $copy, 'original string unmodified';

ok !eval { decode('UTF-8', $copy = $invalid_bytes); 1 }, 'invalid decode errored';
is $invalid_bytes, $copy, 'original string unmodified';

ok !eval { decode_utf8($copy = $invalid_bytes); 1 }, 'invalid decode_utf8 errored';
is $invalid_bytes, $copy, 'original string unmodified';

# invalid lax encode/decode
is encode_lax('UTF-8', $copy = $invalid_characters), $replacement_bytes, 'invalid lax encode';
is $invalid_characters, $copy, 'original string unmodified';

is encode_utf8_lax($copy = $invalid_characters), $replacement_bytes, 'invalid encode_utf8_lax';
is $invalid_characters, $copy, 'original string unmodified';

is decode_lax('UTF-8', $copy = $invalid_bytes), $replacement_characters, 'invalid lax decode';
is $invalid_bytes, $copy, 'original string unmodified';

is decode_utf8_lax($copy = $invalid_bytes), $replacement_characters, 'invalid decode_utf8_lax';
is $invalid_bytes, $copy, 'original string unmodified';

# invalid ascii characters
ok !eval { encode('ASCII', $copy = $invalid_ascii); 1 }, 'invalid ascii errored';
is $invalid_ascii, $copy, 'original string unmodified';

is encode_lax('ASCII', $copy = $invalid_ascii, 1), $replacement_ascii, 'invalid lax ascii';
is $invalid_ascii, $copy, 'original string unmodified';

# Encode::Unicode
my $warnings;
{
  local $SIG{__WARN__} = sub { $warnings = shift };
  ok !eval { encode('UTF-16BE', $copy = $surrogate_characters); 1 }, 'surrogate characters encode to UTF-16';
}
is $surrogate_characters, $copy, 'original string unmodified';
is $warnings, undef, 'no warnings';

undef $warnings;
{
  local $SIG{__WARN__} = sub { $warnings = shift };
  like encode_lax('UTF-16BE', $copy = $surrogate_characters), $surrogate_bytes, 'surrogate characters lax encode to UTF-16';
}
is $surrogate_characters, $copy, 'original string unmodified';
is $warnings, undef, 'no warnings';

undef $warnings;
{
  local $SIG{__WARN__} = sub { $warnings = shift };
  ok !eval { encode('UTF-16BE', $copy = $invalid_characters); 1 }, 'invalid encode to UTF-16';
}
is $invalid_characters, $copy, 'original string unmodified';
is $warnings, undef, 'no warnings';

done_testing;
