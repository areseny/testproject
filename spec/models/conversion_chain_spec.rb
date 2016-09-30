require 'rails_helper'

RSpec.describe ConversionChain, type: :model do

  let!(:demo_step)        { create(:step_class, name: "Step") }
  let!(:recipe_step)      { create(:recipe_step, step_class: demo_step) }
  let!(:conversion_step)  { create(:conversion_step, step_class: demo_step) }
  let!(:conversion_chain) { conversion_step.conversion_chain }

  describe 'model validations' do

    it 'has a valid factory' do
      expect(build(:conversion_chain)).to be_valid
    end

    expects_to_be_invalid_without :conversion_chain, :user, :recipe
  end

  describe '#step_classes' do

    before do
      conversion_chain.update_attribute(:recipe_id, recipe_step.recipe.id)
    end

    it 'should return the step classes' do
      expect(conversion_chain.step_classes).to eq [Conversion::Steps::Step]
    end

  end

  describe '#execute_conversion!' do
    context "if the chain hasn't been saved yet" do
      it 'should fail' do
        new_chain = ConversionChain.new
        expect{new_chain.execute_conversion!}.to raise_error("Chain not saved yet")
        expect(new_chain.executed_at).to be_nil
      end
    end

    context "if the chain already exists" do

      it 'should fail' do
        conversion_chain.execute_conversion!

        expect(conversion_chain.executed_at).to_not be_nil
      end
    end

  end
end