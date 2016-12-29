module Api
  module V1
    class RecipesController < ApplicationController
      before_action :authenticate_api_user!, only: [:index, :show, :create, :update, :destroy, :execute]

      respond_to :json

      def execute
        recipe.ensure_step_installation
        @new_chain = recipe.clone_and_execute(input_files: input_file_param, callback_url: callback_url_param[:callback_url], user: current_api_user)
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
        # ap e.message
        render_unprocessable_error(e)
      end

      def index
        render json: recipes, user_id: current_api_user.id
      end

      def show
        render json: recipe, user_id: current_api_user.id
      rescue => e
        # ap e.message
        # ap e.backtrace
        render_error(e)
      end

      def update
        recipe.update!(recipe_params)
        render json: recipe, root: false
      rescue ActiveRecord::RecordNotFound => e
        render_not_found_error(e)
      end

      def destroy
        recipe.destroy
        render json: recipe, root: false
      rescue => e
        render_not_found_error(e)
      end

      private

      def recipe_params
        params.require(:recipe).permit(:name, :description, :active, :public)
      end

      def recipe_step_params
        params.require(:recipe).permit(steps: [], steps_with_positions: [:step_class_name, :position])
      end

      def input_file_param
        params.require(:input_file)
      end

      def callback_url_param
        params.permit(:callback_url)
      end

      def recipe
        @recipe ||= Recipe.includes(:recipe_steps, {process_chains: :process_steps}).available_to_user(current_api_user.id).find(params[:id])
      end

      def new_recipe
        @new_recipe ||= current_api_user.recipes.new(recipe_params)
      end

      def recipes
        @recipes ||= Recipe.includes(:recipe_steps, :process_chains).available_to_user(current_api_user.id)
      end

    end
  end
end
