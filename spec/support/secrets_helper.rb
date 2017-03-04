module SecretsHelper
  def stub_secrets(secrets)
    Rails.application.secrets.merge!(secrets)
  end
end