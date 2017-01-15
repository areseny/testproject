require 'rake'

# To run:
# $> rake setup:create_user[mystery_person@example.com,secretpassword123]

# Don't use quotes around anything.
# Also, there shouldn't be a space between the email and the password - only a comma.
# Otherwise, you'll get 'Don't know how to build task'

namespace :setup do
  desc "it creates a new user"
  task :create_user, [:name, :password] => [:environment] do |t, args|
    puts "Creating user with arguments: #{args}"
    User.create(email: args[:email], password: args[:password], password_confirmation: args[:password])
  end
end