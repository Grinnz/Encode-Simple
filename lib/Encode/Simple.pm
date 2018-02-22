package Encode::Simple;

use strict;
use warnings;
use Carp ();
use Encode ();
use Exporter 'import';

our $VERSION = '0.001';

our @EXPORT = qw(encode decode);

sub encode {
  my ($encoding, $input, $replace) = @_;
  my $mask = Encode::LEAVE_SRC | ($replace ? Encode::FB_DEFAULT : Encode::FB_CROAK);
  my ($output, $error);
  { local $@; unless (eval { $output = Encode::encode($encoding, $input, $mask); 1 }) { $error = $@ || 'Error' } }
  if (defined $error) {
    $error =~ s/ at .+? line [0-9]+\.\n\z//;
    Carp::croak($error);
  }
  return $output;
}

sub decode {
  my ($encoding, $input, $replace) = @_;
  my $mask = Encode::LEAVE_SRC | ($replace ? Encode::FB_DEFAULT : Encode::FB_CROAK);
  my ($output, $error);
  { local $@; unless (eval { $output = Encode::decode($encoding, $input, $mask); 1 }) { $error = $@ || 'Error' } }
  if (defined $error) {
    $error =~ s/ at .+? line [0-9]+\.\n\z//;
    Carp::croak($error);
  }
  return $output;
}

1;

=head1 NAME

Encode::Simple - Encode and decode text, simply

=head1 SYNOPSIS

  use Encode::Simple qw(encode decode);
  my $characters = decode 'UTF-8', $bytes;
  my $bytes = encode 'UTF-8', $characters;

=head1 DESCRIPTION

This module is a simple wrapper around L<Encode> that presents L</"encode"> and
L</"decode"> functions with straightforward behavior and error handling. See
L<Encode::Supported> for a list of supported encodings.

=head1 FUNCTIONS

All functions are exported by default or individually.

=head2 encode

  my $bytes = encode $encoding, $characters;
  my $bytes = encode $encoding, $characters, 1;

Encodes the input string of characters into a byte string using C<$encoding>.
Throws an exception if the input string contains characters that cannot be
represented in C<$encoding>. If the optional third argument is a true value,
any invalid characters will be encoded as a substitution character instead (the
substitution character used depends on the encoding).

=head2 decode

  my $characters = decode $encoding, $bytes;
  my $characters = decode $encoding, $bytes, 1;

Decodes the input byte string into a string of characters using C<$encoding>.
Throws an exception if the input bytes are not valid in C<$encoding>. If the
optional third argument is a true value, any malformed bytes will be decoded to
the Unicode replacement character (U+FFFD) instead.

=head1 BUGS

Report any issues on the public bugtracker.

=head1 AUTHOR

Dan Book <dbook@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2018 by Dan Book.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)

=head1 SEE ALSO

L<Unicode::UTF8>
