#!/usr/bin/perl -CDS

use 5.014;

use LWP::Simple;
use Net::Plurk;
use JSON;
use Data::Dumper;
use Encode;



# API keys and tokens
my $key           = '';
my $secret        = '';
my $access_token  = '';
my $access_secret = '';


# get total count
my $json = get("http://megane-megane-megane.tumblr.com/api/read/json?num=0");
$json = from_json(substr($json, 22, -2));
my $posts_total = $json->{"posts-total"};

my $s = int rand $posts_total;

# randomly get one
$json = get("http://megane-megane-megane.tumblr.com/api/read/json?start=$s&num=1");

$json = from_json(substr($json, 22, -2));
my $url   = $json->{posts}[0]{url};
my $photo = $json->{posts}[0]{"photo-url-1280"};


say $url;
say $photo;

# start to use Plurk api
our $p = Net::Plurk->new(consumer_key => $key,
                         consumer_secret => $secret);

$p->authorize(access_token => $access_token,
              access_token_secret => $access_secret);

use utf8;
my $json = $p->callAPI('/APP/Timeline/plurkAdd',
                        content => "今日のメガネの娘 (woot)\n$photo\n$url",
                        qualifier => ':');

my $pid =  $json->{plurk_id};

say $pid;
