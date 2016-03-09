module MatcherMethods

  def expects_to_be_invalid_without(*things)
    things.each do |thing|
      it "expects it to have a #{thing}" do
        expect(FactoryGirl.build(:chain_template, thing => nil)).to_not be_valid
      end
    end
  end
end