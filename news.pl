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

##########################################
# solidor.org                            #
##########################################
$mech->get( "http://www.solidot.org/" );

# => http://www.solidot.org/story?sid=32554
my $ref = $mech->find_all_links( url_regex => qr/story\?sid=\d{5}$/);

# get first 6 news's url
my @news_queue = ( uniq( reverse sort map { $_->url_abs() } @$ref ) )[0 .. 5];

##########################################
# 36kr.com                               #
##########################################
$mech->get( "http://www.36kr.com" );

# => http://www.36kr.com/p/200075.html
$ref = $mech->find_all_links( url_regex => qr/p\/\d{6}.html$/);

push @news_queue, (uniq( reverse sort map { $_->url_abs() } @$ref ) )[0 .. 5];


# this is a really idot method to get news title XD
for (@news_queue) {
    $mech->get($_);
    $p->callAPI('/APP/Responses/responseAdd', plurk_id => $pid,
                content => $mech->title() . "\n" . $_,
                qualifier => ':');

    say $_ . "\n" . $mech->title();
    say "==";

    sleep 1;
}

