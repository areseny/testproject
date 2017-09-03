if Rails.env.test?
  Pusher.app_id = "123"
  Pusher.key = "456"
  Pusher.secret = "321"
else
  Pusher.app_id = Rails.application.secrets.slanger_app_id
  Pusher.key = Rails.application.secrets.slanger_key
  Pusher.secret = Rails.application.secrets.slanger_secret
  Pusher.host = Rails.application.secrets.slanger_host
  Pusher.port = Rails.application.secrets.slanger_api_port
end