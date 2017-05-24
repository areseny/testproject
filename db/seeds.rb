require_relative '../spec/step_class_constants'

[Account].each do |klass|
  klass.destroy_all
end

# create a sample account, with a sample service

account = Account.create(name: "Demo User", password: "password", password_confirmation: "password", email: "inkdemo@example.com")
service = Service.create(name: "Demo Service", description: "A sample service", auth_key: "abc123", account: account)

public_recipe1 = Recipe.new(name: "Rot 13 and SHOUTIFIED", description: "Basic obfuscation via ROT-13, and then EVERYTHING IN CAPS", active: true, public: true, account: account)
public_recipe_step1 = public_recipe1.recipe_steps.new(position: 1, step_class_name: StepClassConstants.rot_thirteen_step_class.to_s)
public_recipe_step2 = public_recipe1.recipe_steps.new(position: 2, step_class_name: StepClassConstants.shoutifier_step_class.to_s)
public_recipe1.save!

editoria_recipe = Recipe.new(name: "Editoria Typescript", description: "Convert a docx file to HTML using Coko's own XSweet pipeline and get it ready for Editoria", active: true, public: true, account: account)
editoria_recipe_step1 = editoria_recipe.recipe_steps.new(position: 1, step_class_name: StepClassConstants.xsweet_step_1_extract_step_class.to_s)
editoria_recipe_step2 = editoria_recipe.recipe_steps.new(position: 2, step_class_name: StepClassConstants.xsweet_step_2_notes_step_class.to_s)
editoria_recipe_step3 = editoria_recipe.recipe_steps.new(position: 3, step_class_name: StepClassConstants.xsweet_step_3_scrub_step_class.to_s)
editoria_recipe_step4 = editoria_recipe.recipe_steps.new(position: 4, step_class_name: StepClassConstants.xsweet_step_4_join_step_class.to_s)
editoria_recipe_step5 = editoria_recipe.recipe_steps.new(position: 5, step_class_name: StepClassConstants.xsweet_step_5_collapse_paragraphs_step_class.to_s)
editoria_recipe_step6 = editoria_recipe.recipe_steps.new(position: 6, step_class_name: StepClassConstants.xsweet_step_6_header_promotion_step_class.to_s)
editoria_recipe_step7 = editoria_recipe.recipe_steps.new(position: 7, step_class_name: StepClassConstants.xsweet_step_7_final_rinse_step_class.to_s)
editoria_recipe_step8 = editoria_recipe.recipe_steps.new(position: 8, step_class_name: StepClassConstants.xsweet_step_8_editoria_step_class.to_s)
editoria_recipe.save!