#!/usr/bin/env python3

# original src: https://github.com/ntk148v/polybar-mail/blob/master/polybarmail.py

import argparse
import imaplib
import socket
import time

# alternative shell script without color (total via 'STATUS inbox (messages)'):
# echo $(curl -s --url "imaps://faumail.fau.de:993" --user "<user_mail>":"<user_password" -x 'STATUS inbox (unseen)' | grep -o '[0-9]*')

def print_count(count):
    if count > 0:
        print(f'\uf0e0 {count}', flush=True)
    else:
        print(f'\uf2b7 {count}', flush=True)


def get_count(args, password):
    imap = imaplib.IMAP4_SSL(args.mail_server, args.mail_port)
    imap.login(args.mail_username, password)
    imap.select(mailbox=args.mail_box)
    typ, data = imap.search(None, '(Unseen)')
    if typ != 'OK':
        raise Exception(f'Search command return {typ}')
    count = len(data[0].split())
    return count


def loop(args):
    count_was = -1
    password = ""
    with open(args.mail_password_file, "r") as f:
        password = f.readline()

    while True:
        try:
            count = get_count(args, password)
            if count != count_was:
                print_count(count)
                count_was = count
        except socket.error:
            print("\uf421 -", flush=True)
        time.sleep(int(args.duration))


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('-ms', '--mail_server', default='faumail.fau.de')
    parser.add_argument('-mp', '--mail_port', default='993')
    parser.add_argument('-mu', '--mail_username', default='markus.schoetz@fau.de')
    parser.add_argument('-mpw', '--mail_password_file', default='')
    parser.add_argument('-mb', '--mail_box', default='INBOX')
    parser.add_argument('-dr', '--duration', default=60)
    return parser.parse_args()


def main():
    args = parse_args()
    loop(args)


if __name__ == "__main__":
    main()

