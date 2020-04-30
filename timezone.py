from importlib import util
from datetime import datetime, time
from pytz import timezone
from sys import exit
from time import sleep
import argparse

parser = argparse.ArgumentParser()
parser = argparse.ArgumentParser(description="Convert amongst UTC/IST/CET Timezones")
parser.add_argument("zone", help="u|i|c Input time in UTC|IST|CET")
parser.add_argument("--time", help="Input time in format \"<Y-M-D H:M:S>\" (DoubleQuotes is must) [Default: Current Date Time]", nargs='?')
args = parser.parse_args()
t=args.time
ch=args.zone
f = "%Y-%m-%d %H:%M:%S"

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
    
if t == None:
    
    if ch == 'u':
        while True:
            t=datetime.now().strftime(f)
            utc(t)
            sleep(1)
    elif ch == 'c':
        while True:
            t=datetime.now().strftime(f)
            cet(t)
            sleep(1)
    elif ch == 'i':
        while True:
            t=datetime.now().strftime(f)
            ist(t)
            sleep(1)
    else:
        exit("Wrong Input, Input must be u|i|c")

if ch == 'u':
    utc(t)
elif ch == 'c':
    cet(t)
elif ch == 'i':
    ist(t)
else:
    exit("Wrong Input, Input must be u|i|c")