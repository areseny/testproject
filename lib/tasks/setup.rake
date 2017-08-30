require 'rake'
require_relative '../../spec/step_class_constants'

# To run:
# $> bundle exec rake setup:create_account[mystery_person@example.com,secretpassword123]

# Don't use quotes around anything.
# Also, there shouldn't be a space between the email and the password - only a comma.
# Otherwise, you'll get 'Don't know how to build task'

namespace :setup do
  desc "it creates a new account"
  task :create_account, [:email, :password] => [:environment] do |t, args|
    puts "Creating account with arguments: #{args}"
    Account.create(email: args[:email], password: args[:password], password_confirmation: args[:password])
  end
end

namespace :setup do
  desc "it creates a new account and the default recipes"
  task :create_account_recipe, [:email, :password, :auth] => [:environment] do |t, args|
    puts "Creating account with arguments: #{args}"
    class Constants
      extend StepClassConstants
    end
    acc = Account.find_by(email: args[:email])
    puts acc
    if acc
      puts "Account with email #{args[:email]} exists"
    else
      puts "Account with email #{args[:email]} does not exist"
      account = Account.create(email: args[:email], password: args[:password], password_confirmation: args[:password])
      service = Service.create(name: "Demo Service", description: "A sample service", auth_key: args[:auth], account: account)

      editoria_recipe = Recipe.new(name: "Editoria Typescript", description: "Convert a docx file to HTML using Coko's own XSweet pipeline and get it ready for Editoria", active: true, public: true, account: account)
      editoria_recipe_step1 = editoria_recipe.recipe_steps.new(position: 1, step_class_name: Constants.xsweet_step_1_extract_step_class.to_s)
      editoria_recipe_step2 = editoria_recipe.recipe_steps.new(position: 2, step_class_name: Constants.xsweet_step_2_notes_step_class.to_s)
      editoria_recipe_step3 = editoria_recipe.recipe_steps.new(position: 3, step_class_name: Constants.xsweet_step_3_scrub_step_class.to_s)
      editoria_recipe_step4 = editoria_recipe.recipe_steps.new(position: 4, step_class_name: Constants.xsweet_step_4_join_step_class.to_s)
      editoria_recipe_step5 = editoria_recipe.recipe_steps.new(position: 5, step_class_name: Constants.xsweet_step_5_collapse_paragraphs_step_class.to_s)
      editoria_recipe_step6 = editoria_recipe.recipe_steps.new(position: 6, step_class_name: Constants.xsweet_step_6_handle_lists_step_class.to_s)
      editoria_recipe_step7 = editoria_recipe.recipe_steps.new(position: 7, step_class_name: Constants.xsweet_step_7_header_promotion_step_class.to_s)
      editoria_recipe_step8 = editoria_recipe.recipe_steps.new(position: 8, step_class_name: Constants.xsweet_step_8_final_rinse_step_class.to_s)
      editoria_recipe_step9 = editoria_recipe.recipe_steps.new(position: 9, step_class_name: Constants.xsweet_step_9_editoria_step_class.to_s)
      editoria_recipe.save!
    end
    acc = Account.find_by(email: args[:email])
    puts "Created account with arguments: #{args} and id #{acc.id}"
  end
end
