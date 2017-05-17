require 'rake'

# To run:
# $> bundle exec rake setup:create_account[mystery_person@example.com,secretpassword123]

# Don't use quotes around anything.
# Also, there shouldn't be a space between the email and the password - only a comma.
# Otherwise, you'll get 'Don't know how to build task'

namespace :setup do
  desc "it creates a new account"
  task :create_account, [:name, :password] => [:environment] do |t, args|
    puts "Creating account with arguments: #{args}"
    Account.create(email: args[:email], password: args[:password], password_confirmation: args[:password])
  end
end