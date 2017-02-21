#!/bin/sh

set -x

RAILS_ENV=development bundle exec sidekiq
