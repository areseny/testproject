module Conversion
  module Steps

    class JpgToPng < Step

      def convert(file, options_hash = {})
        super

        updated_image = MiniMagick::Image.open(file) do |photo|
          photo.format('png')
        end

        # FileUploader.new.store!(updated_image)
        updated_image
      end

    end

  end
end