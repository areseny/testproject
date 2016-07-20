module Conversion
  module Steps
    module Validators
      class NeverOk < ValidationStep

        def convert_file(input_file, options_hash = {})
          super
          @errors << "FAILSAUCE"
        end

      end
    end
  end
end
