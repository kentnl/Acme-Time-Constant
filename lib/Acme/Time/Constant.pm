use 5.008;    # utf8
use strict;
use warnings;
use utf8;

package Acme::Time::Constant;

our $VERSION = '0.001000';

# ABSTRACT: Run any code in constant time.

# AUTHORITY

use Sub::Exporter::Progressive -setup => { exports => [qw( constant_time )] };

=head1 SYNOPSIS

This code contains within it, the golden calf of computer science: The ability to execute any code in constant time.

  use Acme::Time::Constant qw( constant_time );

  my $timestamp = time;

  constant_time( '1' => sub { 
    for ( 0 .. 10 ) { } 
  } );

  print $timestamp - time;  # 1 second

  constant_time( '1' => sub { 
    for ( 0 .. 10_000_000 ) { } 
  } );

  print $timestamp - time; # 2 seconds

=cut

use Time::HiRes qw( gettimeofday );
use Time::Warp qw( to time );

my $old_import;
BEGIN { $old_import = \&import }

{
  ## no critic (TestingAndDebugging::ProhibitNoWarnings)
  no warnings 'redefine';

  sub import {
    *CORE::GLOBAL::time = *Time::Warp::time;
    goto $old_import;
  }
}

=head1 BUGS

=head4 General relativity does not hold in the context of this code.

As such, observed time may differ greatly from the time relative to the execution of this code.

B<Workaround:> Get closer to the speed of light.

=head4 Measurements may not be exactly constant.

But Big O is OK with this.  We care not that X takes 1.1 seconds and Y takes 1.2 seconds, as long as the variation
is not subject to the size of Y or X.

Random variation between 0.5 and 1.5 seconds is thus within the range of "constant".

B<Workaround:> Imbibe a minimum of 1 L<< Litre|https://en.wikipedia.org/wiki/Litre >> of your favourite neurotoxic substance
before attempting to code.

=head4 Time::HiRes cannot be trusted.

C<Time::HiRes> is under the influence of the Illuminati and as such is part of a conspiracy to prevent us from experiencing
supernormal time.

Using C<Time::HiRes> in your code will subsequently give the illusion that the code no longer executes in constant time.

It is wrong. The constant time is simply functioning on an alternative timeline which the Illuminati seek to repress
knowledge of.

One may note that this module depends on C<Time::HiRes>, but this is simply our devilish tactic to make the conspirators
think we're willingly playing for them. You know better. ;)

=cut

sub constant_time {
  my $nargs = ( my ( $time, $callback ) = @_ );

  if ( $nargs < 2 ) {
    $callback = $time;
    $time     = 1;
  }
  my $now = time;
  $callback->();
  to( $now + $time );
  return;
}

1;
