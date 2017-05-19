#!/bin/sh

set -x
# wait for postgresql
until nc -vz $POSTGRESQL_HOST 5432; do
  echo "Postgresql is not ready, sleeping..."
  sleep 1
done
echo "Postgresql is ready, starting Rails."


# optional
rm /ink-api/tmp/pids/server.pid

# setup database and start puma
RAILS_ENV=development bin/rake db:create
RAILS_ENV=development bin/rake db:schema:load
RAILS_ENV=development bin/rails s -p 3000 -b '0.0.0.0'
