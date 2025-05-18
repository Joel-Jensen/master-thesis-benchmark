#!/bin/bash

set -eux

# Check if strategy parameter is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <strategy>"
    exit 1
fi

STRATEGY=$1

sudo -u postgres psql -t -c 'DROP DATABASE test'
sudo -u postgres psql -t -c 'CREATE DATABASE test'
sudo -u postgres psql test -t < strategies/$STRATEGY/create.sql

time ./load.sh

./benchmark.sh