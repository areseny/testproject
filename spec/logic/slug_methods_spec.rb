require 'rails_helper'

describe SlugMethods do

  describe '#generate_unique_slug' do
    let!(:slug)        { "abc123" }
    let!(:slug2)       { "abc1234" }
    let!(:chain_spy)   { create(:process_chain, slug: slug) }
    let!(:chain)       { ProcessChain.new }

    context 'when there is another object with a slug already existing' do
      before do
        chain.slug = nil
        allow(ProcessChain).to receive(:all) { [chain_spy] }
        allow(chain).to receive(:generate_slug).and_return(slug, slug2)
      end

      it "creates a slug for an object that doesn't already have one" do
        chain.generate_unique_slug
        expect(chain.slug).to_not eq slug
      end
    end

    it "doesn't create a new slug if one already has been generated for that object" do
      chain.slug = slug

      chain.generate_unique_slug

      expect(chain.slug).to eq slug
    end
  end
end