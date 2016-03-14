module Steps

  class Demo < Step

    # doesn't actually do anything, but good to make sure the step architecture is working properly
    def convert(file, options_hash = {})
      super
      file
    end

  end

end