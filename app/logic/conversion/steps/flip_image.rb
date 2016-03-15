module Conversion
  module Steps

    class FlipImage < Step

      def convert(file, options_hash = {})
        super
        # open does not modify the original image
        flipped_image = MiniMagick::Image.open(file) do |photo|
          photo.flip
        end
        flipped_image
      end

    end
  end
end