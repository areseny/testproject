source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.5.1'
gem 'rails-api'

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

################### file upload ###################3

gem 'carrierwave', github: 'carrierwaveuploader/carrierwave'

################### conversion utilities ########################

# image manipulation
gem 'mini_magick' # requires imagemagick to be installed - http://www.imagemagick.org/script/binary-releases.php

# zip zip
gem 'rubyzip'

# js
gem 'therubyracer'

# file info
gem 'ruby-filemagic'

# downloading things
gem 'httparty'

################### javascript ###############

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'


######################## aux ########################

gem 'awesome_print'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

######################### deployment ##########################

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # factories
  gem 'factory_girl_rails', '~> 4.0'
  # gem 'sidekiq-status'

  gem 'pry'
end

group :test do
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
end
