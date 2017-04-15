module Api
  module V1
    class RecipesController < ApplicationController
      before_action :authenticate_api_account!, only: [:index, :show, :create, :update, :destroy, :execute]

      respond_to :json

      def execute
        recipe.ensure_step_installation
        @new_chain = recipe.clone_and_execute(input_files: input_file_param, callback_url: callback_url_param[:callback_url], account: current_api_account)
        @new_chain.reload
        render json: @new_chain, status: 200
      rescue => e
        ap e.message
        ap e.backtrace
        render_error(e)
      end

      def create
        new_recipe.generate_recipe_steps(recipe_step_params)
        new_recipe.save!
        render json: new_recipe
      rescue => e
        ap e.message
        ap e.backtrace
        render_error(e)
      end

      def index
        render json: recipes, account_id: current_api_account.id
      end

      def show
        render json: recipe, account_id: current_api_account.id
      rescue => e
        # ap e.message
        # ap e.backtrace
        render_error(e)
      end

      def update
        recipe.update!(update_recipe_params)
        render json: recipe, root: false
      rescue => e
        ap e.message
        ap e.backtrace
        render_error(e)
      end

      def destroy
        recipe.destroy
        render json: recipe, root: false
      rescue => e
        render_error(e)
      end

      private

      def recipe_params
        params.require(:recipe).permit(:name, :description, :active, :public)
      end

      def update_recipe_params
        params.require(:recipe).permit(:name, :description, :active, :public)
      end

      def recipe_step_params
        params.require(:recipe).permit(:steps => [], steps_with_positions: [:step_class_name, :position])
      end

      def input_file_param
        params.require(:input_files)
      end

      def callback_url_param
        params.permit(:callback_url)
      end

      def recipe
        @recipe ||= Recipe.includes(:recipe_steps, {process_chains: :process_steps}).available_to_account(current_api_account.id).find(params[:id])
      end

      def new_recipe
        @new_recipe ||= current_api_account.recipes.new(recipe_params)
      end

      def recipes
        @recipes ||= Recipe.includes(:recipe_steps, :process_chains).available_to_account(current_api_account.id)
      end
    end
  end
end

class String
  def to_boolean
    return true if ['true', '1', 'yes', 'on', 't'].include? self
    return false if ['false', '0', 'no', 'off', 'f'].include? self
    nil
  end
end
