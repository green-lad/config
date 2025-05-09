#!/bin/sh

STATE=`nmcli networking connectivity`
if [ $STATE = 'full' ]; then
    new_mails=$(ls $HOME/Maildir/Personal/INBOX/new | wc -l)
    if [[ -n "$new_mails" ]]; then
        printf "\uf0e0 ${new_mails}"
    else
        printf "\uf2b7 0"
    fi
else
    printf "\uf421 -"
fi

