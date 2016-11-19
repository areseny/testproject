require 'rails_helper'

RSpec.describe ProcessChain, type: :model do

  let!(:demo_step)        { "InkStep::BasicStep" }
  let!(:recipe_step)      { create(:recipe_step, step_class_name: demo_step) }
  let!(:conversion_step)  { create(:conversion_step, step_class_name: demo_step) }
  let!(:process_chain) { conversion_step.process_chain }

  describe 'model validations' do

    it 'has a valid factory' do
      expect(build(:process_chain)).to be_valid
    end

    expects_to_be_invalid_without :process_chain, :user, :recipe
  end

  describe '#step_classes' do

    before do
      process_chain.update_attribute(:recipe_id, recipe_step.recipe.id)
    end

    it 'returns the step classes' do
      expect(process_chain.step_classes).to eq [InkStep::BasicStep]
    end

  end

  describe '#execute_conversion!' do
    context "if the chain hasn't been saved yet" do
      it 'fails' do
        new_chain = ProcessChain.new
        expect{new_chain.execute_conversion!}.to raise_error("Chain not saved yet")
        expect(new_chain.executed_at).to be_nil
      end
    end

    context "if the chain already exists" do

      it 'fails' do
        process_chain.execute_conversion!

        expect(process_chain.executed_at).to_not be_nil
      end
    end
  end

  describe '#map_results' do
    subject { create(:process_chain) }

    let(:some_file)           { File.new('spec/fixtures/files/plaintext.txt') }

    let(:runner_step1)        { double(:conversion_object, errors:[], output_files: some_file, version: "1.2.7") }
    let(:runner_step2)        { double(:conversion_object, errors:["oh noes!"], output_files: nil, version: "0.2.1") }
    let(:runner)              { double(:recipe_execution_runner, step_array: [runner_step1, runner_step2]) }

    let(:conversion_step1)    { create(:conversion_step, process_chain: subject, position: 1, output_file: "nothing") }
    let(:conversion_step2)    { create(:conversion_step, process_chain: subject, position: 2, output_file: "nada") }

    before do
      subject.map_results(runner, [conversion_step1, conversion_step2])

      conversion_step1.reload
      conversion_step2.reload
    end

    it 'maps the version correctly' do
      expect(conversion_step1.version).to eq "1.2.7"
      expect(conversion_step2.version).to eq "0.2.1"
    end

    it 'maps the errors correctly' do
      expect(conversion_step1.execution_errors).to eq "[]"
      expect(conversion_step2.execution_errors).to eq "[\"oh noes!\"]"
    end

    it 'maps the output files correctly' do
      expect(conversion_step1.output_file_name).to eq "plaintext.txt"
      expect(conversion_step2.output_file_name).to eq nil
    end
  end
end

# runner.step_array.each_with_index do |runner_step, index|
#   step_model = conversion_steps[index]
#   step_model.execution_errors = [runner_step.errors].flatten
#   step_model.output_file = runner_step.output_files
#   # if runner_step.output_files.respond_to(:map)
#   #   step_model.output_file = runner_step.output_files.map(&:open)
#   # elsif runner_step.output_files.respond_to(:open)
#   #   step_model.output_file = runner_step.output_files.open
#   # end
#   step_model.save!
# end