#!/bin/sh
set -eu

# Bootstrap is done
[ -f /opt/garage_up ] || exit 1

# Garage is started & working
garage status >/dev/null 2>&1