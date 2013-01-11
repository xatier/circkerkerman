#!/usr/bin/perl -CDS

# ver 0.2
use utf8;
use warnings;
use 5.014;

use Net::Plurk;
use LWP::Simple;
use WWW::Mechanize;
use Data::Dumper;
use JSON;
use Encode;

$|++;


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



# get bot channel
my $json        = $p->callAPI('/APP/Realtime/getUserChannel');
my $req_channel = $json->{comet_server} . '&new_offset=';
my $new_offset  = -1;


while (1) {

    # listen the bot channel
    my $req = get($req_channel . $new_offset);
    my @new_plurk = ();
    my @new_response = ();

    if ($req =~ /new_offset": \d+/) {

        my $decoded = from_json("[" . substr($req, 28, -2) . "]");

        $new_offset  = $decoded->[0]{new_offset};
        my $msg_hash = $decoded->[0]{data}[0];

        if (defined $msg_hash->{type}) {
            # say Dumper $msg_hash;
            if ($msg_hash->{type} eq 'new_plurk') {
                my $owner_id = $msg_hash->{user_id};
                say "owner id: $owner_id";
                if ($msg_hash->{replurkers_count} != 0) {
                    say $msg_hash->{content_raw} . "\n" . 
                        "pid: $msg_hash->{plurk_id}";
                    say "已轉噗，不解釋";
                    goto cont;
                }
                push @new_plurk, [$msg_hash->{content_raw},
                                  $msg_hash->{plurk_id}];
            }
            elsif ($msg_hash->{type} eq 'new_response') {
                my $responser_id = $msg_hash->{response}{user_id};
                say "responser id: $responser_id  / $msg_hash->{user}{$responser_id}{nick_name}";
                if ($msg_hash->{plurk}{replurkers_count} != 0) {
                    say $msg_hash->{response}{content_raw} . "\n" . 
                        "$msg_hash->{response_count} 樓 / " .
                        "pid: $msg_hash->{response}{plurk_id}";
                    say "已轉噗，不解釋";
                    goto cont;
                }
                push @new_response, [$msg_hash->{response}{content_raw},
                                     $msg_hash->{response}{plurk_id},
                                     $msg_hash->{response_count}];
            }
        }
        else {
            say "@@?";
            $Data::Dumper::Indent = 0;
            say Dumper $decoded;
            $Data::Dumper::Indent = 2;
        }
    }


    for (@new_plurk) {
        say "plurk    ==> $_->[0] , id: $_->[1]";
        # %Dict%
        if ($_->[0] =~ /^%Dict%:/i) {
            Dict($_->[0], $_->[1]);
        }
        # %Date%
        elsif ($_->[0] =~ /^%date%/i ) {
            Date($_->[0], $_->[1]);
        }
        # %Calc%
        elsif ($_->[0] =~ /^%calc%:/i ) {
            Calc($_->[0], $_->[1]);
        }
        # Youtube
        elsif ($_->[0] =~ /^((點歌)|(想聽))/ ) {
            Youtube($_->[0], $_->[1]);
        }
        # xiami.com
        elsif ($_->[0] =~ /^((蝦米)|(xiami))/ ) {
            xiami($_->[0], $_->[1]);
        }
        # play with my db  XD
        Kerkerman($_->[0], $_->[1]);
    }

    
    for (@new_response) {
        say "response ==> $_->[0] , id: $_->[1] : $_->[2] 樓";
        #if ($_->[2] == 4 and int rand time % 10000 < 1500) {
        # delete the fifth floor function
        if (1 == 0) {
            my @fifth_floor = ("五樓！", "五樓！(dance)",
                               "潮爽的撿到五樓ㄌ :P",
                               "五樓~ (banana_rock)", 
                               "我是專業的五樓！(haha)",
                               "人在五樓，身不由己", 
                               "五樓的高度就是不一樣 (banana_rock)",
                               "安安五樓",
                               ("http://emos.plurk.com/d1cd47f003572d7c2c8fb700ffd73258_w47_h47.gif"x5)."五樓",
                               "根據台灣主計處的年度調查，批踢踢的專業資深成員，大多住在五樓。"
                          );
            select undef, undef, undef, 0.25;

            $p->callAPI('/APP/Responses/responseAdd', plurk_id => $_->[1], 
                    content => $fifth_floor[int rand time % @fifth_floor]
                    , qualifier => ':');
            say "get fifthfloor";
        }
        else {
            say "do nothing ˊ_>ˋ";
        }
    }

cont:
    say "== cont. =================";
    sleep 1;
}

# look up ydict
sub Dict {

    say "Dict: $_[0], $_[1]";

    # get the string which our user want to lookup
    my $lookup = "\'" . substr ($_[0], 8) . "\'";
    say "$lookup";

    # chect it in ydict
    my $result = `./ydict -c $lookup`;

    # grep what i really want (Chinese part)
    my $r = flter($result);

    # find nothing: $r = []
    if (!defined $r->[0]) {
        say "nothing";
        $json = $p->callAPI('/APP/Responses/responseAdd', plurk_id => $_[1], 
                            content => "No reslut. for $_[0]  :'(", 
                            qualifier => ':');
    }
    else {
        say @$r;
        # results in ydict
        for (@$r) {
            $json = $p->callAPI('/APP/Responses/responseAdd', plurk_id => $_[1], 
                                content => $_, qualifier => ':');
        }
    }
}

sub flter {
    # original result in ydict
    my $res = shift;
    my @lines = split /\n/, $res;
    my @ret;
    my $j;
    my $ok = 0;
    for (@lines) {
        # n / v / vt / vi / prep / ad / a / pron
        if(/^n\./ or /^v[it]?\./ or /^prep\./ or /^ad\./ or /^a\./ or /^pron\./) {
            if ($ok >= 1) {
                push @ret, $j;
                $j = "";
                $ok = 0;
            }
            $j .= "$_\n";
        }
        elsif (/\s\s\d+/) {
            $j .= "$_\n";
            $ok++;
        }
    }
    push @ret, $j;
    return \@ret;
}


# what time is it?
sub Date {
    my $r = "現在時間 => " . `date`;
    say "Date $r";
    $json = $p->callAPI('/APP/Responses/responseAdd', plurk_id => $_[1], 
                        content => $r, qualifier => ':');
}


# calulator
sub Calc {
    my $expr = substr($_[0], 8);
    say "Calc: \'$expr\'";

    my $r;
    if ($expr !~ /[a-z]/i) {
        my $answer = ` echo '$expr' | bc`;

        # if $answer is a number
        if ($answer =~ /\d+/) {
            $r = $answer;
        }
        else {
            $r = "哭哭我算不出來 :'("
        }
    }
    else {
        $r = "哭哭我算不出來 :'("
    }

    
    say "Calc =>   $expr = $r";

    $json = $p->callAPI('/APP/Responses/responseAdd', plurk_id => $_[1], 
                        content => $r, qualifier => ':');
}


# youtube search
sub Youtube {

    my $mech = WWW::Mechanize->new();
    $_[0] =~ s/想聽//;
    $_[0] =~ s/點歌//;
    my $url = "http://www.youtube.com/results?hl=en&search_query=$_[0]";
    say $url;

    $mech->get( $url );

    my $ref = $mech->find_all_links( url_regex => qr/watch\?v=/i );

    my @playlist = ();
    for (@$ref) {
        if ($_->url() =~ /watch\?v=.{11}/ and $_->text() =~ /Watch Later/) {
            push @playlist, $_->url_abs();
        }
        last if (@playlist == 3);
    }

    if (@playlist > 0) {
        $json = $p->callAPI('/APP/Responses/responseAdd', plurk_id => $_[1], 
                             content => '@circkerkerman 為您帶來:', 
                             qualifier => ':');
        for (@playlist) {
            say;
            $json = $p->callAPI('/APP/Responses/responseAdd', plurk_id => $_[1], 
                                 content => $_, 
                                 qualifier => ':');
        }
    }
}


sub xiami {
    my $mech = WWW::Mechanize->new();
    $_[0] =~ s/蝦米//;
    $_[0] =~ s/xiami//;
    my $url = "http://www.xiami.com/search?key=$_[0]";
    say $url;

    $mech->get( $url );
    my $ref = $mech->find_all_links( url_regex => qr/song\/showcollect\/id\/\d+/i );

    if (@$ref > 0) {
        $json = $p->callAPI('/APP/Responses/responseAdd', plurk_id => $_[1], 
                             content => '@circkerkerman 為您帶來:', 
                             qualifier => ':');
        for (@$ref) {
            say $_->text() . "\n" . $_->url_abs();
            $json = $p->callAPI('/APP/Responses/responseAdd', plurk_id => $_[1], 
                                 content => $_->text() . "\n" . $_->url_abs(), 
                                 qualifier => ':');
        }
    }
}

# the @circkerkerman bot
sub Kerkerman {
    # check my database
    my $r =  dbSearch($_[0]);
    # if not nothing
    if ($r ne "") {
        say "kerkerman RE => $r"; 
        $json = $p->callAPI('/APP/Responses/responseAdd', plurk_id => $_[1], 
                             content => $r, qualifier => ':');
    }
    else {
        say "no search reault in db";
    }
}


sub dbSearch {
    open DB, "<", "db";
    my $x = shift;
    my @re;
    repeat:
    while (my $a = <DB>) {
        if ($a =~ /= Begin ===========================/) {
            my $y = <DB>;
            chomp($y);
            if ($x =~ $y) {
                while (my $b = <DB>) {
                    if ($b =~ /= End =============================/) {
                        goto repeat;
                    }
                    push @re, $b;
                }
            }
        }
    }
    close DB;
    if (@re == 0) {
        return "";
    }
    return (substr($re[int(rand @re)], 2));
}

