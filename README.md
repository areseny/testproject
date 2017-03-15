### INK

Ink is an API. It provides an extensible step-based framework for file conversions as a first use case, but is intended to be a more generalised framework for all kinds of steps needed when preparing materials for publication.

## Ruby version

2.2.3

## Rails version

This project is an API, and therefore is using the `rails-api` gem.

## Setup (for developers)

Install `rbenv` (recommended) or `rvm` and install the required ruby version (see `.ruby-version.rb`)

Make sure postgres is installed (recommended 9.1+, minimum 8.2)

Copy the `config/database.yml.sample` file into `config/database.yml` and change the credentials to match whatever postgres setup you have.

Copy the `config/ink_api.yml.sample` file into `config/ink_api.yml` and put in the storage directory you'd like to use for files.

Run `bundle` and usual rake db restoration procedure. Use `db:schema:load`.

Run the rake tasks for creating a user if you want, or use `rails console`.

Run slanger (replace variables APP_KEY, SECRET, ADDRESS and PORT): `slanger --app_key APP_KEY --secret SECRET -w ADDRESS:PORT`. For development, you can use the command `slanger --app_key 44332211ffeeddccbbaa --secret aabbccddeeff11223344 -a localhost:4567 -w localhost:4444 --verbose` (the `--verbose` tag will help you debug if you need it).

### Install 'slanger'

Go to [the Slanger homepage](https://github.com/stevegraham/slanger) and install it according to the 'server setup' directions.

The Slanger web service uses localhost port 4444 by default, but this can be changed by setting the `SLANGER-PORT` and 'SLANGER-SERVER' env variables

## Setup (for production)

In addition to the above, on the server:

- Set up an environment variable as per `secrets.yml` for Devise token auth.
- Set up nginx and passenger to act as web server.

Copy the `env.sample` file into `.env`. Populate with the environment variables needed in the `deployable_settings` bit.

### Step Third-party Binary Dependencies

These are listed under the gem readme files for the appropriate step gems. 

### Run it

Run the Rails server in a terminal - `bundle exec rails s`

Run redis in another terminal - `redis-server`

Run sidekiq in another terminal - `bundle exec sidekiq`

Check `localhost:3000/anyone` to see if it's up.

Once it is up and running, run the rake task in `lib/setup.rake` to create some users.

## Further development

### Adding a new step

To write a new step, create a gem (you can host it under RubyGems). I've included code so that the step files get autoloaded when Rails is present.
 
The example I'll use here is `InkStep::RotThirteen` included in the gem `coko_demo_steps`. 

You can install in a few ways:

Manually: `gem specific_install -l https://gitlab.coko.foundation/INK/coko_demo_steps`. You'll have to update manually whenever there is an update.

Via gemfile, you can edit the gemfile to include the line `gem 'coko_demo_steps', git: 'git@gitlab.coko.foundation:INK/coko_demo_steps.git` and run `bundle install`. However, with this method, when you pull the latest changes to INK, your gemfile will be removed.

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