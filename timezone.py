from importlib import util
from datetime import datetime, time, date
from pytz import timezone
from sys import exit
import time
import argparse

parser = argparse.ArgumentParser()
parser = argparse.ArgumentParser(description="Convert amongst UTC/IST/CET Timezones")
parser.add_argument("-z", help="u|i|c Input time in UTC|IST|CET [Default: Current Zone]", nargs='?')
parser.add_argument("-t", help="Input time in format \"<H:M:S>\" (DoubleQuotes is must) [Default: Current Time]", nargs='?')
parser.add_argument("-d", help="Input date in format \"<Y-M-D>\" (DoubleQuotes is must) [Default: Current Date]", nargs='?')
args = parser.parse_args()
d=args.d
t=args.t
ch=args.z

def utc(t):
    tm=datetime.strptime(t,f)
    ist=timezone('UTC').localize(tm, is_dst=None).astimezone(timezone('Asia/Kolkata'))
    cet=timezone('UTC').localize(tm, is_dst=None).astimezone(timezone('Europe/Paris'))
    print("\r\tIST: {}\tCET: {}".format(ist.strftime(f),cet.strftime(f)), end="")

def ist(t):
    tm=datetime.strptime(t,f)
    utc=timezone('Asia/Kolkata').localize(tm, is_dst=None).astimezone(timezone('UTC'))
    cet=timezone('Asia/Kolkata').localize(tm, is_dst=None).astimezone(timezone('Europe/Paris'))
    print("\r\tUTC: {}\tCET: {}".format(utc.strftime(f),cet.strftime(f)), end="")

def cet(t):
    tm=datetime.strptime(t,f)
    utc=timezone('Europe/Paris').localize(tm, is_dst=None).astimezone(timezone('UTC'))
    ist=timezone('Europe/Paris').localize(tm, is_dst=None).astimezone(timezone('Asia/Kolkata'))
    print("\r\tUTC: {}\tIST: {}".format(utc.strftime(f),ist.strftime(f)), end="")
    
if d == None and t != None:
    d=date.today().strftime("%Y-%m-%d")
    
if ch == None:
    if -time.timezone == 19800:
        ch='i'
    elif -time.timezone == 7200:
        ch='c'
    else:
        ch='u'

f = "%Y-%m-%d %H:%M:%S"
t=d+' '+t
    
if t == None:
    
    if ch == 'u':
        while True:
            t=datetime.now().strftime(f)
            utc(t)
            time.sleep(1)
    elif ch == 'c':
        while True:
            t=datetime.now().strftime(f)
            cet(t)
            time.sleep(1)
    elif ch == 'i':
        while True:
            t=datetime.now().strftime(f)
            ist(t)
            time.sleep(1)
    else:
        exit("Wrong Input, Input must be u|i|c")

else:
    if ch == 'u':
        utc(t)
    elif ch == 'c':
        cet(t)
    elif ch == 'i':
        ist(t)
    else:
        exit("Wrong Input, Input must be u|i|c")
