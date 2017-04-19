#!/bin/sh
set -e;
echo "named";
named;
echo "$@";
exec "$@";
