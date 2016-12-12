require 'rails_helper'

describe SlugMethods do

  describe '#generate_unique_slug' do
    let!(:slug)        { "abc123" }
    let!(:slug2)       { "abc1234" }
    let!(:chain_spy)   { create(:process_chain, slug: slug) }
    let!(:new_step)    { ProcessChain.new(slug: nil) }

    context 'when there is another object with a slug already existing' do
      before do
        allow(ProcessChain).to receive(:all) { [chain_spy] }
        allow(new_step).to receive(:generate_slug).and_return(slug, slug2)
      end

      it "creates a slug for an object that doesn't already have one" do
        new_step.generate_unique_slug

        expect(new_step.slug).to eq slug2
      end
    end

    it "doesn't create a new slug if one already has been generated for that object" do
      new_step.slug = slug

      new_step.generate_unique_slug

      expect(new_step.slug).to eq slug
    end
  end
end