source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '5.0.0.1'

gem 'active_model_serializers'

gem 'rack-cors', :require => 'rack/cors'

################### authentication ####################

gem 'devise'
gem 'devise_token_auth'
gem 'omniauth'
gem 'jwt'

################### async ##########################

gem 'sidekiq'

# sidekiq-web
gem 'sinatra', :require => nil
gem 'health-monitor-rails'

################### data #####################

# Use postgresql as the database for Active Record
gem 'pg', '~> 0.15'

################### basic steps #############################

# gem 'ink_step', path: "~/projects/coko/ink-step"

gem 'ink_step', git: 'git@gitlab.coko.foundation:INK/ink-step.git'
gem 'inkstep_coko_demo_steps', git: 'git@gitlab.coko.foundation:INK/inkstep_coko_demo_steps.git'
gem 'inkstep_coko_conversion', git: 'git@gitlab.coko.foundation:INK/inkstep_coko_conversion.git'

################### javascript ###############

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'


######################## aux ########################

gem 'awesome_print'

# we're actually using slanger
gem 'pusher'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # factories
  gem 'factory_girl_rails', '~> 4.0'
  # gem 'sidekiq-status'

  gem 'pry'
end

group :test do
  gem 'rails-controller-testing'
  gem 'rspec-rails', '~> 3.0'
  gem 'json_spec'
  # gem 'rspec-sidekiq'

  # db teardown/cleanup
  gem 'database_cleaner'

  # mocking external services during testing
  gem 'webmock'

  gem 'pusher-fake'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  # better web server than webrick
  gem 'thin'

  ######################### deployment ##########################

  gem 'capistrano', '~> 3.4.0'
  gem 'capistrano-rails', '~> 1.1'
  gem 'capistrano-bundler', '~> 1.1.2'
  gem 'capistrano-rbenv', github: "capistrano/rbenv"
  gem 'capistrano-sidekiq'

  gem 'sshkit-sudo'
end