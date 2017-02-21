#!/bin/sh

set -x

RAILS_ENV=test bundle exec rake spec
