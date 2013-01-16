#!/usr/bin/perl -CDS

use 5.014;

use XML::Feed;
use WWW::Shorten::TinyURL;
use Net::Plurk;

# max articles number each feed
use constant THRESHOLD => 5;


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
                        content => 'Today\'s RSS feeds', qualifier => ':');

my $pid =  $json->{plurk_id};


# RSS feed urls
my @urls = (
    "http://feeds2.feedburner.com/solidot",
    "http://www.36kr.com/feed",
    "http://pansci.tw/feed",
    "http://blog.gslin.org/feed",
    "https://www.linux.com/rss/feeds.php",
    "http://www.linuxplanet.org/blogs/?feed=rss2",
    "http://perlsphere.net/atom.xml",
    "http://planet.linux.org.tw/atom.xml",
    "http://security-sh3ll.blogspot.com/feeds/posts/default",
    "http://feeds.feedburner.com/TheGeekStuff",
    "http://coolshell.cn/feed",
);


my @data = ();
for my $url (@urls) {
    my $feed = XML::Feed->parse(URI->new($url)) or die XML::Feed->errstr;

    say $feed->title;
    my $count = 0;
    for my $entry ($feed->entries) {
        push @data, [$feed->title, $entry->title, $entry->link];
        $count++;
        last if ($count >= THRESHOLD);
    }
}

for (@data) {
    say $_->[0];
    say $_->[1];
    say $_->[2];
    my $short =  makeashorterlink($_->[2]);
    say $short;

    $p->callAPI('/APP/Responses/responseAdd', plurk_id => $pid,
                content => $_->[0] . " | " . $_->[1]. "\n" . $short,
                qualifier => ':');

    say "========";
    sleep 1;
}
