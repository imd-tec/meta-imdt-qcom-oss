#!/bin/sh
# One CI job per LAVA board across repos. Forced command of the CI lock key
# on the LAVA server, in ~/.ssh/authorized_keys:
#   command="<path>/board-lock.sh <lock root>",restrict ssh-ed25519 AAAA... ci-board-lock
# The workflow runs: ssh -i <lock key> <host> acquire|release <board-tag> <owner>
#   acquire exits 0 taken, 1 held, 2 stale lock broken
#   release removes the lock only if <owner> holds it
set -u
set -f
ROOT=${1:?lock root}
# shellcheck disable=SC2086 # split the client's words, globbing is off
set -- ${SSH_ORIGINAL_COMMAND:-}
if [ $# -ne 3 ]; then
	echo "usage: acquire|release <board-tag> <owner>" >&2
	exit 64
fi
CMD=$1
BOARD=$2
OWNER=$3
case $BOARD in "" | *[!A-Za-z0-9-]*) echo "bad board tag" >&2; exit 64 ;; esac
case $OWNER in "" | *[!A-Za-z0-9._/#-]*) echo "bad owner" >&2; exit 64 ;; esac
LOCK=$ROOT/$BOARD
# Longer than any job can hold the board, so only a lock whose job died is broken
STALE=$((4 * 3600))

holder() { cat "$LOCK/owner" 2>/dev/null || echo "<unknown>"; }

case $CMD in
acquire)
	mkdir -p "$ROOT"
	if mkdir "$LOCK" 2>/dev/null; then
		echo "$OWNER" > "$LOCK/owner"
		date +%s > "$LOCK/since"
		echo "taken by $OWNER"
		exit 0
	fi
	# A lock being taken has no 'since' yet, so treat a missing one as new
	SINCE=$(cat "$LOCK/since" 2>/dev/null || date +%s)
	AGE=$(($(date +%s) - SINCE))
	if [ "$AGE" -gt "$STALE" ]; then
		echo "breaking stale lock held by $(holder) for ${AGE}s"
		rm -rf "$LOCK"
		exit 2
	fi
	echo "held by $(holder) for ${AGE}s"
	exit 1
	;;
release)
	if [ "$(holder)" = "$OWNER" ]; then
		rm -rf "$LOCK"
		echo "released by $OWNER"
	else
		echo "not released: held by $(holder), not $OWNER"
	fi
	;;
*)
	echo "usage: acquire|release <board-tag> <owner>" >&2
	exit 64
	;;
esac
