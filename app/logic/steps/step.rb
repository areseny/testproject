module Steps
  class Step

    # doesn't do anything! just returns the file as-is
    def convert_file(input_file, options_hash = {})
      raise "No file specified" unless input_file
      input_file
    end

    def self.all_steps
      [Demo, XmlToHtml]
    end

  end

end