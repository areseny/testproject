### INK

Ink is an API. It provides an extensible step-based framework for file conversions as a first use case, but is intended to be a more generalised framework for all kinds of steps needed when preparing materials for publication.

## Ruby version

2.2.3

## Rails version

This project is an API, and therefore is using the `rails-api` gem.

## Setup

Make sure postgres is installed (recommended 9.1+, minimum 8.2)

Copy the `config/database.yml.sample` file into `config/database.yml` and change the credentials to match whatever postgres setup you have.

`bundle` and usual rake db restoration procedure. Use `db:schema:load`.

### Step Third-party Binary Dependencies

These are listed under the gem readme files for the appropriate step gems. 

### Run it

Run the Rails server in a terminal - `bundle exec rails s`

Run redis in another terminal - `redis-server`

Run sidekiq in another terminal - `bundle exec sidekiq`

Check `localhost:3000/anyone` to see if it's up.

## Further development

### Adding a new step

To write a new step, create a gem (you can host it under RubyGems). I've included code so that the step files get autoloaded when Rails is present.
 
The example I'll use here is `RotThirteen`. 

You can install in a few ways:

Manually: `gem specific_install -l https://gitlab.coko.foundation/INK/rot_thirteen`. You'll have to update manually whenever there is an update.

Via gemfile, you can edit the gemfile to include the line `gem 'rot_thirteen', git: 'git@gitlab.coko.foundation:INK/rot_thirteen.git` and run `bundle install`. However, with this method, when you pull the latest changes to INK, your gemfile will be removed.

I'm working on a separate custom `StepGemfile` that gets installed as well, so that an instance's installed steps will be preserved. Stay tuned!

### Upgrading API version

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

Contact charlie@coko.foundation for all your (ink-related) support needs.

## License

MIT.