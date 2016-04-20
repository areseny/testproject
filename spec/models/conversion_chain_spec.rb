require 'rails_helper'

RSpec.describe ConversionChain, type: :model do

  describe 'model validations' do

    it 'has a valid factory' do
      expect(FactoryGirl.build(:conversion_chain)).to be_valid
    end

    expects_to_be_invalid_without :conversion_chain, :user, :recipe
  end

  describe '#step_classes' do

    let!(:demo_step)        { FactoryGirl.create(:step_class, name: "Step") }
    let!(:recipe_step)      { FactoryGirl.create(:recipe_step, step_class: demo_step) }
    let!(:conversion_step)  { FactoryGirl.create(:conversion_step, step_class: demo_step) }
    let!(:conversion_chain) { conversion_step.conversion_chain }

    before do
      conversion_chain.update_attribute(:recipe_id, recipe_step.recipe.id)
    end

    it 'should return the step classes' do
      expect(conversion_chain.step_classes).to eq [Conversion::Steps::Step]
    end

  end

  def step_classes
    recipe.recipe_steps.sort_by(&:position).inject([]) do |result, recipe_step|
      result << recipe_step.step_class.behaviour_class
    end
  end

end