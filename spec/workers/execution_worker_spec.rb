require 'rails_helper'

describe ExecutionWorker do

  describe '#process_step_hash' do

    let!(:process_chain)      { create(:process_chain) }
    let!(:process_step1)      { create(:process_step, process_chain: process_chain, position: 1) }
    let!(:process_step2)      { create(:process_step, process_chain: process_chain, position: 2) }
    let!(:process_step3)      { create(:process_step, process_chain: process_chain, position: 3) }
    let!(:process_step4)      { create(:process_step, process_chain: process_chain, position: 4) }

    subject { ExecutionWorker.new }

    before do
      subject.instance_variable_set(:@process_chain, process_chain)
    end

    it 'generates the hash properly' do
      expected = [ process_step1, process_step2, process_step3, process_step4]

      expect(subject.process_steps_in_order).to eq expected
    end

  end

end