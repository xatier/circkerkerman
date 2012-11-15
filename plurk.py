#!/usr/bin/python

# an very eazy plurk api example

import re
import json
import urllib2
from PlurkAPI import PlurkAPI

plurk = PlurkAPI('', '')
plurk.authorize('', '')


def bot ():
    plurk.callAPI('/APP/Timeline/plurkAdd', {'content' : 'i want karma!!', 'qualifier' : ':'})

if __name__ == '__main__' :
    bot()
