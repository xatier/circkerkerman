#!/usr/bin/perl -CDS

use 5.014;
no warnings;
use WWW::Mechanize;
use Data::Dumper;
use List::MoreUtils qw(uniq);
use Net::Plurk;


# API keys and tokens
my $key           = '';
my $secret        = '';
my $access_token  = '';
my $access_secret = '';

# start to use Plurk api
our $p = Net::Plurk->new(consumer_key => $key, 
                         consumer_secret => $secret);

$p->authorize(access_token => $access_token, 
              access_token_secret => $access_secret);

my $json = $p->callAPI('/APP/Timeline/plurkAdd',
                        content => 'Today\'s Solidot News', qualifier => ':');

my $pid =  $json->{plurk_id};

# new Mechanize
my $mech = WWW::Mechanize->new();

$mech->get( "http://www.solidot.org/" );

# find news id like this =>  http://www.solidot.org/story?sid=32554
my $ref = $mech->find_all_links( url_regex => qr/story\?sid=\d{5}$/);

# get absolute links
my @news = map { $_->url_abs() } @$ref;

# get first 15 news
@news = ( uniq( reverse sort @news ) )[0 .. 14];


# this is a really idot method to get news title XD
for (@news) {
    $mech->get($_);
    $p->callAPI('/APP/Responses/responseAdd', plurk_id => $pid,
                content => $_ . "\n" . $mech->title(),
                qualifier => ':');

    say $_ . "\n" . $mech->title();
    say "==";

    select undef, undef, undef, 0.5;
}
