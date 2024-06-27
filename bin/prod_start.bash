#!/bin/bash
set -eu

docker-compose -f docker-compose.yml -f docker-compose.prod.yml "$@"

