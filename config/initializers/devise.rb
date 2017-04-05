Devise.setup do |config|
  config.secret_key = Rails.application.secrets.devise_secret_key
end