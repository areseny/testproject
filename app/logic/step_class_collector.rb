class StepClassCollector

  class << self
    def step_class_hash
      step_classes.map{|klass| { name: klass.name, description: klass.description, accepted_parameters: klass.accepted_parameters } }
    end

    def step_gem_hash
      step_gems.each do |gem_info_hash|
        gem_info_hash[:step_classes] = gem_info_hash[:step_classes].map{|klass| { name: klass.name, description: klass.description } }
      end
    end

    def step_classes
      klasses = step_gems.map{|gem_hash| gem_hash[:step_classes]}.flatten
      [InkStep::Base] + klasses.sort_by(&:to_s)
    end
  end

  private

  class << self
    def step_gems
      # base_inkstep_gem = Bundler.load.specs.select{ |gem| gem.name.match /^ink_step$/ }.first
      # step_gems = [gem_hash(base_inkstep_gem)]

      # Find any gem starting with `inkstep_` using Bundler's gem specs
      ink_step_gem_specs = Bundler.load.specs.select{ |gem| gem.name.match /(\Aink_step\z|\Ainkstep_\w+)/ }
      # structure:
      # { name: "inkstep_example_step_gem", version: 1.1, git_version: "abcdef", step_classes: [InkStep::AStep, InkStep::AnotherStep], source: "https://gitlab.coko.foundation/inkstep_example_step_gem" }
      ink_step_gem_specs.inject([]) do |array, gem_spec|
        array << gem_hash(gem_spec)
      end
    end

    def gem_hash(gem_spec)
      {}.tap do |gem_hash|
        gem_hash[:name] = gem_spec.name
        gem_hash[:version] = gem_spec.version
        gem_hash[:git_version] = gem_spec.git_version
        gem_hash[:repo] = get_repo(gem_spec.source)
        gem_hash[:step_classes] = load_step_classes(gem_spec: gem_spec)
      end
    end

    def get_repo(source)
      if source.is_a?(Bundler::Source::Git)
        return source.uri
      elsif source.is_a?(Bundler::Source::Path)
        return source.send(:original_path)
      end
      source.to_s
    end

    def load_step_classes(gem_spec:)
      # e.g. /home/charlie/.rbenv/versions/2.2.3/lib/ruby/gems/2.2.0/bundler/gems/inkstep_coko_demo_steps-7eafb06c791d/
      gem_path = gem_spec.full_gem_path
      step_classes = []

      # Dive into it and grab anything in the `lib/#{gemname minus inkstep_}/ink_step` of which InkStep::Base is an ancestor
      if gem_spec.name == "ink_step"
        step_directory = File.join(gem_path, "lib")
      else
        step_directory = File.join(gem_path, "lib", gem_spec.name.gsub("inkstep_", ""))
      end

      begin
        Dir.chdir(File.join(step_directory, "ink_step")) do
          Dir.glob(File.join(step_directory, "**", "*_step.rb")).collect do |pathname|
            class_name = Pathname.new(pathname.chomp('.rb')).relative_path_from(Pathname.new(step_directory)).to_s.camelize
            begin
              klass = class_name.constantize
              step_classes << klass if klass.ancestors.include? InkStep::Base
            rescue => e
              ap "Couldn't load the class #{class_name} in gem #{gem_spec.name} located in #{pathname}"
              ap e2.message
            end
          end
        end
      rescue => e
        ap "There's a problem getting the files from the directory #{File.join(step_directory, "ink_step")}... Try running `bundle install`"
        ap "message: #{e.message}"
        return []
      end
      step_classes
    end
  end
end