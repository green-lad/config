#!/bin/sh

exec st -e neomutt -a "${@##mailto:?attach=}"
