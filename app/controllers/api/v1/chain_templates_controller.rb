module Api
  module V1
    class ChainTemplatesController < ApplicationController
      before_action :authenticate_api_user!, only: [:index, :show, :create, :update, :destroy, :execute, :members_only]

      respond_to :json

      def execute
        @new_chain = chain_template.clone_to_conversion_chain(execution_params)
        @new_chain.save!
        @new_chain.execute_conversion!
        render json: @new_chain, status: 200
      rescue => e
        # puts e.message
        render_error(e)
      end

      def create
        new_chain_template.generate_step_templates(step_template_params)
        new_chain_template.save!
        render json: new_chain_template, root: false
      rescue => e
        render_unprocessable_error(e)
      end

      def index
        render json: chain_templates.to_json
      end

      def show
        render json: chain_template, include: ['step_templates'], root: false
      rescue => e
        render_not_found_error(e)
      end

      def update
        chain_template.update!(chain_template_params)
        render json: chain_template, root: false
      rescue ActiveRecord::RecordNotFound => e
        render_not_found_error(e)
      end

      def destroy
        chain_template.destroy
        render json: chain_template, root: false
      rescue => e
        render_not_found_error(e)
      end

      # test methods

      def anyone
        render json: {
                   data: {
                       message: "Welcome to api version 1, guest!"
                   }
               }, status: 200
      end

      def members_only
        render json: {
                   data: {
                       message: "Welcome to api version 1, #{current_api_user.name}",
                       user: current_api_user
                   }
               }, status: 200
      end

      private

      def chain_template_params
        params.require(:chain_template).permit(:name, :description, :active)
      end

      def step_template_params
        params.permit(steps: [], steps_with_positions: [:name, :position])
      end

      def execution_params
        params.require(:input_file)
        # params.require(files: [])
      end

      def chain_template
        @chain_template ||= current_api_user.chain_templates.find(params[:id])
      end

      def new_chain_template
        @new_chain_template ||= current_api_user.chain_templates.new(chain_template_params)
      end

      def chain_templates
        @chain_templates ||= current_api_user.chain_templates.active
      end

    end
  end
end
