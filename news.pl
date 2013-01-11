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
                        content => 'Today\'s News', qualifier => ':');

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


for (@news_queue) {
    $mech->get($_);
    # a hacky approach
    # Ref. http://stackoverflow.com/questions/9312154/wget-page-title
    my $title = `wget --quiet -O - $_  | sed -n -e \'H;
                \${x;s!.*<head[^>]*>\\(.*\\)</head>.*!\\1!;
                tnext;b;:next;s!.*<title>\\(.*\\)</title>.*!\\1!p}\'`;

    $p->callAPI('/APP/Responses/responseAdd', plurk_id => $pid,
                content => $title . "\n" . $_,
                qualifier => ':');

    say $_ . "\n" . $title;
    say "==";

    sleep 5;
}


