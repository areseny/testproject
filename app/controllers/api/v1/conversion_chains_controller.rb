module Api
  module V1
    class ConversionChainsController < ApplicationController
      before_action :authenticate_api_user!, only: [:execute]

      respond_to :json

      def execute
        chain.execute
      rescue => e
        render_error(e)
      end

      private

      def conversion_chain_params
        params.require(:conversion_chain).permit(:input_file)
      end
    end
  end
end
