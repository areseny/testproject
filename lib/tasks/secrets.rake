require 'rake'

namespace :check_secrets do
  desc "checks that all secrets are set3------"
  task :create_user, [:name, :password] => [:environment] do |t, args|
    puts "Checking secrets"

    path_to_secrets = File.dirname(__FILE__) + '/../config/secrets.yml'
    erb = ERB.new(File.read(path_to_secrets))
    secrets = YAML.load(erb.result(binding))
    # environment = ENV['RAILS_ENV'].downcase
    # puts "'#{ENV.inspect}'"
    environment = "production"

    missing_keys = secrets[environment].select { |_, value| value.nil? }

    if missing_keys.any?
      raise "Please set the #{missing_keys.map { |k, v| k.upcase }.join(', ')} environment variable(s)."
    end
  end
end
