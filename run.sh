#!/bin/sh

set -e

createdb persist_ser || true

( cd preupgrade \
  && stack build \
  && stack run \
  && psql -d persist_ser -c 'select * from persist_ser;' -x \
)

( cd postupgrade \
  && stack build \
  && stack run \
)
