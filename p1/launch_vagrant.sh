#!/usr/bin/sh
set -a
source ./.env
exec vagrant "$@"
