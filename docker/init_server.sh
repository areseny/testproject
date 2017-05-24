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
bin/rake db:create
bin/rake db:schema:load
bin/bundle exec rake setup:create_account_recipe[$INK_EMAIL,$INK_PASSWORD,$INK_AUTH]

bin/rails s -p 3000 -b '0.0.0.0'
