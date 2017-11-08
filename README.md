### INK

Ink is an API. It provides an extensible step-based framework for file conversions as a first use case, but is intended to be a more generalised framework for all kinds of steps needed when preparing materials for publication.

## Ruby version

2.2.3

## Rails version

It uses Rails 5 in API version.

## Setup with docker
Follow the instructions here https://docs.docker.com/compose/install/ to install docker and docker-compose
To run the stack:

    docker-compose build
    docker-compose up

## Setup gitlab CI

Go to /admin/runners on gitlab and copy the ci token.

Go to an accessible server and install a gitlab runner https://docs.gitlab.com/runner/

Make sure the runner's host has docker-engine installed

Register the runner with the ci token

  Choose docker+machine as executor type and docker:latest as the image

  You can do this with this command
  `gitlab-runner register -n -u $GITLAB_CI_URL --docker-image docker:latest -r $GITLAB_TOKEN --executor docker+machine --docker-privileged`

Now whenever you push to the repo the rspec tests will run.


## Setup (for developers)

Linux (debian/ubuntu)

Install `rbenv` (recommended) or `rvm` and install the required ruby version (see `.ruby-version.rb`)

Make sure postgres is installed (recommended 9.1+, minimum 8.2)

Copy the .env.sample file to .env

Fill the .env file variables with your values

Run `eval $(cat .env | sed 's/^/export /')` to export the variables to the environment

~~Copy the `config/database.yml.sample` file into `config/database.yml` and change the credentials to match whatever postgres setup you have.~~

~~Copy the `config/ink_api.yml.sample` file into `config/ink_api.yml` and put in the storage directory you'd like to use for files.~~

In the project directory (e.g. `/usr/you/ink-api`), run `gem install bundler` and `gem install rake` if you need to

Copy `StepGemfile.sample` and name the copy `StepGemfile`.

Run `bundle install` to install the required gems.

Run `bundle exec rake db:create` to create the database, then `bundle exec rake db:schema:load` to create all the tables. If you have any issues, check `config/database.yml` to ensure the credentials are correct.

Run the seeds `bundle exec rake db:seed` for some sample recipes and a sample account and service.

If you want to add some custom accounts, run the rake task for creating an account (see `lib/tasks/setup.rake`). You can always use `bundle exec rails console`.

### Install 'slanger'

Go to [the Slanger homepage](https://github.com/stevegraham/slanger) and install it according to the 'server setup' directions.

The Slanger web service uses localhost port 4444 by default, but this can be changed by setting the `SLANGER-PORT` and 'SLANGER-SERVER' env variables

Run slanger (replace variables APP_KEY, SECRET, ADDRESS and PORT): `slanger --app_key APP_KEY --secret SECRET -w ADDRESS:PORT`. For development, you can use the command `slanger --app_key 44332211ffeeddccbbaa --secret aabbccddeeff11223344 -a localhost:4567 -w localhost:4444 --verbose` (the `--verbose` tag will help you debug if you need it).

## Setup (for production)

In addition to the above, on the server:

- Set up an environment variable as per `secrets.yml` for Devise token auth.
- Set up nginx and passenger to act as web server.

Copy the `env.sample` file into `.env`. Populate with the environment variables needed in the `deployable_settings` bit.

Copy the `StepGemfile.sample` file into `StepGemfile`. Add any step gems you'd like to include (there are some there to get you started)

Run slanger on the target server (replace APP_KEY, SECRET, ADDRESS and PORT): `slanger --app_key APP_KEY --secret SECRET -w ADDRESS:PORT`. For development, you can use the command `slanger --app_key 44332211ffeeddccbbaa --secret aabbccddeeff11223344 -a 0.0.0.0:4567 -w 0.0.0.0:4444 --verbose` (the `--verbose` tag will help you debug if you need it).

### Step Third-party Binary Dependencies

These are listed under the gem readme files for the appropriate step gems.

### Run it

Run the Rails server in a terminal - `bundle exec rails s`

Run redis in another terminal - `redis-server`

Run sidekiq in another terminal - `bundle exec sidekiq`

Check `localhost:3000/api/anyone` to see if it's up.

Once it is up and running, run the rake task in `lib/setup.rake` to create some users.

### Adding a new step gem to the server

Modify the `StepGemfile` (or make one if you don't have one already - there's a `StepGemfile.sample` to copy)
The dependencies are handled by Bundler, so be aware that there may be version incompatibilities if ink-api and a step gem require different versions of the same dependency. 
In most cases, Bundler cna handle this by itself, but it may take some fiddling by you to get it right.

Run `bundle install`

Restart the server on production by running `touch $rails_root/tmp/restart.txt`. Replace `$rails_root` with your Rails root directory (where the Gemfile is)

## Further development

### Adding a new step

To write a new step, create a gem (you can host it under RubyGems). I've included code so that the step files get autoloaded when Rails is present.

The example I'll use here is `InkStep::Coko::RotThirteen` included in the gem `coko_demo_steps`.

You can install in a few ways:

Via StepGemfile. Include the line `gem 'coko_demo_steps', git: 'git@gitlab.coko.foundation:INK/coko_demo_steps.git` and run `bundle install`.

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
