#!/usr/bin/env python3

# original src: https://github.com/ntk148v/polybar-mail/blob/master/polybarmail.py

import argparse
import imaplib
import time


def print_count(count, colornormal, colorhighlight, prefix):
    output = ''
    prefix_output = '%{F' + colornormal + '}' + prefix + '%{F-}'
    number_output = '%{F' + colornormal + '}' + str(count) + '%{F-}'

    if count > 0:
        prefix_output = '%{F' + colorhighlight + '}' + prefix + '%{F-}'

    print(f'{prefix_output} {number_output}', flush=True)


def get_count(args):
    # Connect to mail server
    imap = imaplib.IMAP4_SSL(args.mail_server, args.mail_port)
    imap.login(args.mail_username, args.mail_password)
    imap.select(mailbox=args.mail_box)
    typ, data = imap.search(None, '(Unseen)')
    if typ != 'OK':
        raise Exception(f'Search command return {typ}')
    count = len(data[0].split())
    return count


def loop(args):
    count_was = -1

    while True:
        count = get_count(args)
        if count != count_was:
            print_count(count, args.colornormal, args.colorhighlight, args.prefix)
            count_was = count
        time.sleep(int(args.duration))


def parse_args():
    parser = argparse.ArgumentParser()

    parser.add_argument('-ms', '--mail_server', default='faumail.fau.de')
    parser.add_argument('-mp', '--mail_port', default='993')
    parser.add_argument('-mu', '--mail_username', default='markus.schoetz@fau.de')
    parser.add_argument('-mpw', '--mail_password', default='genericPsw')
    parser.add_argument('-mb', '--mail_box', default='INBOX')

    parser.add_argument('-p', '--prefix', default='\uf0e0')
    parser.add_argument('-c', '--colorhighlight', default='#ff0000')
    parser.add_argument('-cn', '--colornormal', default='#000000')
    parser.add_argument('-ns', '--nosound', action='store_true')
    parser.add_argument('-dr', '--duration', default=60)
    return parser.parse_args()


def main():
    args = parse_args()
    loop(args)


if __name__ == "__main__":
    main()

