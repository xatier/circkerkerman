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
    p = os.popen('date "+%F, %A"')
    j = plurk.callAPI('/APP/Timeline/plurkAdd', 
            {'content' : p.readline() + 
             ' Technet.tw Geek Calender | 程式/設計宅民曆',
             'qualifier' : ':'})
    p.close()

    pid = j[u'plurk_id']

    if pid is None:
        return


    os.system('w3m -dump "http://technet.tw" | '
              'head -n 26 | sed -e \'/^$/d\' -e \'1,3d\'| '
              'sed -e \'1,4{N; s/\\n/ /}\' > t')

    c = 0
    s = ""
    f = open("t")

    for line in f:
        if line == "宜\n":
            s = line[:-1] + "："
            c = 1
            continue
        elif line == "忌\n" or line == "程式小格言\n":
            plurk.callAPI('/APP/Responses/responseAdd',
                    {'plurk_id' : pid,
                     'content' : s,
                     'qualifier' : ':'})
            print s
            s = line[:-1] + "："
        elif c == 0:
            plurk.callAPI('/APP/Responses/responseAdd',
                    {'plurk_id' : pid,
                      'content' : line,
                      'qualifier' : ':'})
            print line,
        elif c == 1:
            s += line[:-1]

    plurk.callAPI('/APP/Responses/responseAdd',
            {'plurk_id' : pid,
             'content' : s,
             'qualifier' : ':'})
    print s

    f.close()


if __name__ == '__main__' :
    bot()
