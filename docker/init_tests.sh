#!/bin/sh

set -x
# setup database and start tests

RAILS_ENV=test bin/rake db:create
RAILS_ENV=test bundle exec rake spec
