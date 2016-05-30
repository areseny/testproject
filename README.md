## INK

Ink is an API. It provides an extensible step-based framework for file conversions.

## Ruby version

2.2.3

## Rails version

This project is an API, and therefore is using the `rails-api` gem.

## Setup

Make sure postgres is installed (recommended 9.1+, minimum 8.2)

Copy the `config/database.yml.sample` file into `config/database.yml`

`bundle` and usual rake db restoration procedure. Use `db:schema:load`.

## Mailcatcher

Install Mailcatcher by running `gem install mailcatcher`

## ImageMagick

Used for steps with image manipulation.

Installation directions: http://www.imagemagick.org/script/binary-releases.php

## Saxon

On your machine, set up the Saxon XSLT parser (needed for some steps)
http://mvnrepository.com/artifact/net.sf.saxon/Saxon-HE/9.7.0-4 (jar only)
Installation directions for Ubuntu: https://gist.github.com/bauhouse/21afa826ff81409b97b0
Installation directions for Linux and Windows: http://www.saxonica.com/saxon-c/index.xml#installing

## Run it

Run the Rails server in a terminal - `bundle exec rails s`

Run redis in another terminal - `redis-server`

Run sidekiq in another terminal - `bundle exec sidekiq`

Check `localhost:3000/recipes/anyone` to see if it's up.

## Adding a new step

To add a new step, add the step logic under its own file in `app/logic/steps`. Subclass `Conversion::Steps::Step`. I've left a couple of sample ones - `RotThirteen` is a basic one that involves serving back a different file than was supplied.

Add the class name into the array `StepClass.all_steps` method. Otherwise the system won't know it's there.

## Upgrading API version

To prevent breaking consumers of this API with upgrades, this API is versioned with a simple mechanism that looks for the API version specified in the request header.

To add a new API version (Assuming upgrading from v1 to v2):

* Copy the routes in `config/routes` to add `v2` and set it as the default.

* Copy the following directories and call the copy `v2`
  * `controllers/api/v1`
  * `spec/controllers/v1`
  * `spec/features/v1`

In each of these, you'll have to rename the `V1` module to `V2`.
Open `spec/controllers/v1/version.rb` and `spec/integration/v1/version.rb` Change the version in your copy to `v2`.

## Support

Contact the Collaborative Knowledge Foundation (ink-related) support needs.

## License

MIT.