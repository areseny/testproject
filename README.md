## INK

Ink is an API and extensible step-based framework for file conversions.

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

## Run it

Run the Rails server in a terminal - `bundle exec rails s`

Run Mailcatcher - `mailcatcher`

Run redis in another terminal - `redis-server`

Run sidekiq in another terminal - `bundle exec sidekiq`

Go to localhost:3000 to see if it's up.

## Adding a new step

To add a new step, add the step logic under its own file in `app/logic/steps`. Subclass `Conversion::Steps::Step`.

Add the class name into the array `StepClass.all_steps` method. Otherwise the system won't know it's there.

## Upgrading API version

To prevent breaking consumers of this API with upgrades, this API is versioned with a simple mechanism that looks for the API version specified in the request header.

To add a new API version (Assuming upgrading from v1 to v2):

* Copy the routes in `config/routes` to add `v2` and set it as the default.

* Copy the following directories and call the copy `v2`
** `controllers/api/v1`
** `spec/controllers/v1`
** `spec/features/v1`

In each of these, you'll have to rename the `V1` module to `V2`.
Open `spec/controllers/v1/version.rb` and `spec/integration/v1/version.rb` Change the version in your copy to `v2`.

## Support

Contact charlie@enspiral.com for all your (ink-related) support needs.

## License

MIT.