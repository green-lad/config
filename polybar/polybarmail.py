#!/usr/bin/env python3

# original src: https://github.com/ntk148v/polybar-mail/blob/master/polybarmail.py

import argparse
import configparser
import imaplib
from pathlib import Path
import subprocess
import sys
import time


def print_count(count, colornormal, colorhighlight, prefix):
    output = ''
    prefix_output = '%{F' + colornormal + '}' + prefix + '%{F-}'
    number_output = '%{F' + colornormal + '}' + str(count) + '%{F-}'

    if count > 0:
        prefix_output = '%{F' + colorhighlight + '}' + prefix + '%{F-}'

    print(f'{prefix_output} {number_output}', flush=True)


def get_count(config):
    mail_server = config['default']['mail_server']
    mail_port = config['default']['mail_port']
    mail_username = config['default']['mail_username']
    mail_password = config['default']['mail_password']
    mail_box = config['default']['mail_box']

    # Connect to mail server
    imap = imaplib.IMAP4_SSL(mail_server, mail_port)
    imap.login(mail_username, mail_password)
    imap.select(mailbox=mail_box)
    typ, data = imap.search(None, '(Unseen)')
    if typ != 'OK':
        raise Exception(f'Search command return {typ}')
    count = len(data[0].split())
    return count


def loop(args, config):
    count_was = -1

    while True:
        count = get_count(config)
        if count != count_was:
            print_count(count, args.colornormal, args.colorhighlight, args.prefix)
            count_was = count
        if not args.nosound and count_was < count and count > 0:
            subprocess.run(['canberra-gtk-play', '-i', 'message'])
        time.sleep(int(args.duration))


def get_count(config):
    mail_server = config['default']['mail_server']
    mail_port = config['default']['mail_port']
    mail_username = config['default']['mail_username']
    mail_password = config['default']['mail_password']
    mail_box = config['default']['mail_box']

    # Connect to mail server
    imap = imaplib.IMAP4_SSL(mail_server, mail_port)
    imap.login(mail_username, mail_password)
    imap.select(mailbox=mail_box)
    typ, data = imap.search(None, '(Unseen)')
    if typ != 'OK':
        raise Exception(f'Search command return {typ}')
    count = len(data[0].split())
    return count


def loop(args, config):
    count_was = -1

    while True:
        count = get_count(config)
        if count != count_was:
            print_count(count, args.colornormal, args.colorhighlight, args.prefix)
            count_was = count
        if not args.nosound and count_was < count and count > 0:
            subprocess.run(['canberra-gtk-play', '-i', 'message'])
        time.sleep(int(args.duration))


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '--config', default=f'{Path.home()}/.config/polybar/mail.ini')
    parser.add_argument('-p', '--prefix', default='\uf0e0')
    parser.add_argument('-c', '--colorhighlight', default='#ff0000')
    parser.add_argument('-cn', '--colornormal', default='#000000')
    parser.add_argument('-ns', '--nosound', action='store_true')
    parser.add_argument('-dr', '--duration', default=60)
    return parser.parse_args()


def main():
    args = parse_args()
    config = configparser.ConfigParser()
    config.read(args.config)
    loop(args, config)


if __name__ == "__main__":
    main()

