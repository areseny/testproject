source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '5.0.0.1'

gem 'active_model_serializers'

gem 'rack-cors', :require => 'rack/cors'

################### authentication ####################

gem 'devise'
gem 'devise_token_auth'
gem 'omniauth'

################### async ##########################

gem 'sidekiq'
gem 'sinatra', :require => nil # for sidekiq-web

################### data #####################

# Use postgresql as the database for Active Record
gem 'pg', '~> 0.15'

################### file upload ###################

gem 'carrierwave', github: 'carrierwaveuploader/carrierwave'

################### basic steps #############################

gem 'ink_step', git: 'git@gitlab.coko.foundation:INK/step.git'
gem 'rot_thirteen', git: 'git@gitlab.coko.foundation:INK/rot_thirteen.git'
gem 'epub_calibre', git: 'git@gitlab.coko.foundation:INK/epub_calibre.git'
gem 'docx_to_html_pandoc', git: 'git@gitlab.coko.foundation:INK/docx_to_html_pandoc.git'
gem 'xsweet_pipeline', git: 'git@gitlab.coko.foundation:INK/xsweet_pipeline.git'
gem 'inkstep-pdf-conversion', git: 'git@gitlab.coko.foundation:INK/inkstep-pdf-conversion.git'

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