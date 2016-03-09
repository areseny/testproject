module Requests
  module JsonHelpers
    def body_as_json
      JSON.parse(response.body)
    end
  end
end