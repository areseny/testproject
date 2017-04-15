module Api
  module V1
    module Overrides
      class SessionsController < ::DeviseTokenAuth::SessionsController

        def render_create_success
          render json: { data: ActiveModelSerializers::SerializableResource.new(@resource).as_json }
        end
      end
    end
  end
end