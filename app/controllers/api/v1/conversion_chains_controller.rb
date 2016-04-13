module Api
  module V1
    class ConversionChainsController < ApplicationController
      before_action :authenticate_api_user!, only: [:execute]

      respond_to :json

      def execute
        conversion_chain_params.inspect #somehow, removal of this line causes the controller test to fail :/
        conversion_chain.execute_conversion!
        render json: @conversion_chain, status: 200
      rescue => e
        # puts e.message
        render_error(e)
      end

      def download_file
        send_file(conversion_chain.input_file.path,
                  :disposition => 'attachment',
                  :url_based_filename => true)
      end

      private

      def conversion_chain_params
        params.require(:input_file)
      end

      def conversion_chain
        @conversion_chain ||= current_api_user.conversion_chains.find(params[:id])
      end
    end
  end
end
