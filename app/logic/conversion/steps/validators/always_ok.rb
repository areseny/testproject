module Conversion
  module Steps
    module Validators
      class AlwaysOk < ValidationStep

        def convert_file(input_file, options_hash = {})
          super
          "Looks great! A-OK!"
        end

      end
    end
  end
end