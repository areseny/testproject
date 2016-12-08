require 'rails_helper'

describe SlugMethods do

  describe '#generate_unique_slug' do
    let!(:slug)        { "abc123" }
    let!(:slug2)       { "abc1234" }
    let!(:snail_spy)   { Snail.new(slug) }
    let!(:new_snail)   { Snail.new(nil) }

    context 'when there is another object with a slug already existing' do
      before do
        allow(Snail).to receive(:respond_to?).and_call_original
        allow(Snail).to receive(:respond_to?).with(:all) { true }
        allow(Snail).to receive(:new) { snail_spy }
        allow(Snail).to receive(:all) { [snail_spy] }
        allow(new_snail).to receive(:generate_slug).and_return(slug, slug2)
      end

      it "creates a slug for an object that doesn't already have one" do
        new_snail.generate_unique_slug

        expect(new_snail.slug).to eq slug2
      end
    end

    it "doesn't create a new slug if one already has been generated for that object" do
      new_snail.slug = slug

      new_snail.generate_unique_slug

      expect(new_snail.slug).to eq slug
    end
  end

  class Snail
    include SlugMethods

    attr_accessor :slug

    def initialize(slug)
      @slug = slug
    end

    def self.all
      raise "ha!"
    end
  end
end