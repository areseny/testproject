#!/bin/sh

set -x
# setup database and start tests
RAILS_ENV=development bin/rake db:schema:load
RAILS_ENV=test bundle exec rake spec
