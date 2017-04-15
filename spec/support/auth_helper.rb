def expire_token(account, client_id)
  account.tokens[client_id]['expiry'] = (Time.now - (DeviseTokenAuth.token_lifespan.to_f + 10.seconds)).to_i
  account.save!
end