#!/bin/sh
# One CI job per LAVA board across repos. Runs on the LAVA server over ssh:
#   board-lock.sh acquire <lock dir> <owner>  exit 0 taken, 1 held, 2 stale lock broken
#   board-lock.sh release <lock dir> <owner>  removes the lock only if <owner> holds it
set -u
CMD=$1
LOCK=$2
OWNER=$3
# Longer than any job can hold the board, so only a lock whose job died is broken
STALE=$((4 * 3600))

holder() { cat "$LOCK/owner" 2>/dev/null || echo "<unknown>"; }

case $CMD in
acquire)
	mkdir -p "$(dirname "$LOCK")"
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
	echo "usage: $0 acquire|release <lock dir> <owner>" >&2
	exit 64
	;;
esac
