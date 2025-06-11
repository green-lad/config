#!/bin/sh

newmaildir="$HOME/Maildir/Personal/INBOX/new"

print_state() {
    STATE=`nmcli networking connectivity`
    new_mails=$(ls "$newmaildir" | wc -l)
    if [ $STATE != 'full' ]; then
        printf "\uf421 -\n"
    elif [[ -n "$new_mails" ]]; then
        printf "\uf0e0 ${new_mails}\n"
    else
        printf "\uf2b7 0\n"
    fi
}

mbsync -a -q
print_state
inotifywait -q -m -e create -e move -e delete "$newmaildir" | while read -r "event" ; do
    print_state
done
