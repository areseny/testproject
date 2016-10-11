module Api
  module V1
    class ConversionChainsController < ApplicationController
      include ExecutionErrors

      before_action :authenticate_api_user!, only: [:retry, :download_file]
      before_action :authorise_user!

      respond_to :json

      def retry
        @new_chain = conversion_chain.retry_conversion!(current_api_user: current_api_user)
        render json: @new_chain, status: 200
      rescue => e
        # puts e.message
        # puts e.backtrace
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

      def authorise_user!
        if conversion_chain.user != current_api_user
          e = ExecutionErrors::NotAuthorisedError.new("That recipe is not accessible to you.")
          render_error(e)
        end
      end
    end
  end
end
