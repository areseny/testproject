require 'rails_helper'

RSpec.describe StepClassCollector do

  subject { StepClassCollector }

  describe '#step_class_hash' do
    before do
      allow(StepClassCollector).to receive(:step_classes).and_return(sample_step_classes)
    end

    let(:expected_result) {
      [
          { name: InkStep::ExampleStep.name, description: InkStep::ExampleStep.description, accepted_parameters: InkStep::ExampleStep.accepted_parameters },
          { name: InkStep::MysteryStep.name, description: InkStep::MysteryStep.description, accepted_parameters: InkStep::MysteryStep.accepted_parameters }

      ]
    }

    it 'returns the step classes in a hash' do
      expect(subject.step_class_hash).to match_array expected_result
    end
  end

  describe '#step_classes' do
    let(:expected_result) {
      [InkStep::Base, InkStep::MysteryStep, InkStep::ExampleStep, InkStep::AmazingStep, InkStep::DelightfulStep]
    }

    before do
      allow(StepClassCollector).to receive(:step_gems).and_return(step_gem_output)
    end

    it 'parses the gem hash correctly' do
      expect(subject.step_classes).to match_array expected_result
    end
  end

  describe '#step_gem_hash' do

    let(:expected_output) {
      [
          { name: "inkstep_another_example_step_gem", version: 0.3, git_version: "fedcba", step_classes: [{ name: "InkStep::MysteryStep", description: InkStep::MysteryStep.description}, { name: "InkStep::ExampleStep", description: InkStep::ExampleStep.description }], source: "https://gitlab.coko.foundation/inkstep_another_example_step_gem" },
          { name: "inkstep_example_step_gem", version: 1.1, git_version: "abcdef", step_classes: [{ name: "InkStep::AmazingStep", description: InkStep::AmazingStep.description }, { name: "InkStep::DelightfulStep", description: InkStep::DelightfulStep.description }], source: "https://gitlab.coko.foundation/inkstep_example_step_gem" }
      ]
    }

    before do
      allow(StepClassCollector).to receive(:step_gems).and_return(step_gem_output)
    end

    specify do
      expect(subject.step_gem_hash).to match_array expected_output
    end
  end

  def sample_step_classes
    [
        InkStep::ExampleStep,
        InkStep::MysteryStep
    ]
  end

  def step_gem_output
     [
        { name: "inkstep_another_example_step_gem", version: 0.3, git_version: "fedcba", step_classes: [InkStep::MysteryStep, InkStep::ExampleStep], source: "https://gitlab.coko.foundation/inkstep_another_example_step_gem" },
        { name: "inkstep_example_step_gem", version: 1.1, git_version: "abcdef", step_classes: [InkStep::AmazingStep, InkStep::DelightfulStep], source: "https://gitlab.coko.foundation/inkstep_example_step_gem" }
     ]
  end

  class InkStep::ExampleStep < InkStep::ConversionStep
    def version
      "1.2"
    end

    def description
      "An example"
    end
  end

  class InkStep::MysteryStep < InkStep::ConversionStep
    def version
      "0.3"
    end

    def description
      "What could it possibly do??"
    end
  end

  class InkStep::AmazingStep < InkStep::ConversionStep
    def version
      "7.8"
    end

    def description
      "AMAZING!!!!1"
    end
  end

  class InkStep::DelightfulStep < InkStep::ConversionStep
    def version
      "5.6"
    end

    def description
      "This is a high quality step"
    end
  end
end