#!/usr/bin/sh
set -a
source conf/.env
exec vagrant "$@"
