#!/bin/sh

set -x
# wait for postgresql
until nc -vz $POSTGRESQL_HOST 5432; do
  echo "Postgresql is not ready, sleeping..."
  sleep 1
done
echo "Postgresql is ready, starting Sidekiq."

bundle exec sidekiq
