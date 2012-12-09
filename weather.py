#!/usr/bin/python
# -*- encoding:utf8 -*-

import re
import json
import urllib2
import os
from PlurkAPI import PlurkAPI

plurk = PlurkAPI('', '')
plurk.authorize('', '')


def bot ():
    j = plurk.callAPI('/APP/Timeline/plurkAdd', 
            {'content' : '今日氣象 http://emos.plurk.com/b02203682d2fee5d2869e20a03c05907_w48_h48.gif ', 
             'qualifier' : ':'})

    pid = j['plurk_id']

    if pid is None:
        return

    os.system('w3m -dump http://tw.weather.yahoo.com/today.html | '
              'awk \'{print $1 $2 $3 $4}\' | grep -P "\[\d\d\]" | '
              'sed -e \'s/\[..\]/ /\'> w')

    c = 0
    s = ""
    f = open("w")

    for line in f:
        s += line
        if c < 3:
            c += 1
        else:
            plurk.callAPI('/APP/Responses/responseAdd', 
                    {'plurk_id' : pid,
                     'content' : s,
                     'qualifier' : ':'})
            s = ""
            c = 0

    plurk.callAPI('/APP/Responses/responseAdd', 
            {'plurk_id' : pid,
              'content' : s,
              'qualifier' : ':'})

    f.close()


if __name__ == '__main__' :
    bot()
