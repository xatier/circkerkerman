#!/usr/bin/python

# the example from Dada's Blog 
# http://blog.urdada.net/2011/10/28/426/

import re
import json
import urllib2
from PlurkAPI import PlurkAPI

# my plurk OAuth keys
plurk = PlurkAPI('', '')
plurk.authorize('', '')


def bot ():
    # listen uer channel
    comet = plurk.callAPI('/APP/Realtime/getUserChannel')
    comet_channel = comet.get('comet_server') + "&amp;new_offset=%d"
    jsonp_re = re.compile('CometChannel.scriptCallback\((.+)\);\s*');
    new_offset = -1

    while True:
        try:
            # get data in my channel
            req = urllib2.urlopen(comet_channel % new_offset, timeout=80)
            rawdata = req.read()
            match = jsonp_re.match(rawdata)

            if match:
                rawdata = match.group(1)

            data = json.loads(rawdata)
            new_offset = data.get('new_offset', -1)
            msgs = data.get('data') 

            # no messages right now
            if not msgs:
                continue

            # let's see what's happened in my plurk river
            for msg in msgs:
                if msg.get('type') == 'new_plurk':
                    # i have new plurk
                    pid = msg.get('plurk_id')
                    content = msg.get('content_raw')
                    print "plurk_id [%s]: %s" % (pid, content)
                    """
                    # if content included the string "hello" then response "world"
                    if content.find("hello") != -1 or content.find("Hello") != -1:
                        # NOTE: the second parameter is a dictoinary
                        plurk.callAPI('/APP/Responses/responseAdd',
                                      {'plurk_id': pid,
                                       'content': 'world!!',
                                       'qualifier': ':' })

                    # now, you can write a functoin to process new plurk
                    """# and you can use regex to get keywords in the content_raw

        # catch KeyboardInterrupt 
        except KeyboardInterrupt:
            print "you press ^C !!"
            break

        except:
            print "something error QQ"
            break

if __name__ == '__main__':
    bot()
    
