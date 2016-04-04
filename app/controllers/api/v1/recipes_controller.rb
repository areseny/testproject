module Api
  module V1
    class RecipesController < ApplicationController
      before_action :authenticate_api_user!, only: [:index, :show, :create, :update, :destroy, :execute, :members_only]

      respond_to :json

      def execute
        @new_chain = recipe.clone_to_conversion_chain(execution_params)
        @new_chain.save!
        @new_chain.execute_conversion!
        render json: @new_chain, status: 200
      rescue => e
        # puts e.message
        render_error(e)
      end

      def create
        new_recipe.generate_recipe_steps(recipe_step_params)
        new_recipe.save!
        render json: new_recipe, include: ['recipe_steps'], root: false
      rescue => e
        render_unprocessable_error(e)
      end

      def index
        render json: recipes, include: ['recipe_steps', 'conversion_chains'], root: false
      end

      def show
        render json: recipe, include: ['recipe_steps'], root: false
      rescue => e
        render_not_found_error(e)
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

      def recipe_params
        params.require(:recipe).permit(:name, :description, :active)
      end

      def recipe_step_params
        params.permit(steps: [], steps_with_positions: [:name, :position])
      end

      def execution_params
        params.require(:input_file)
        # params.require(files: [])
      end

      def recipe
        @recipe ||= current_api_user.recipes.find(params[:id])
      end

      def new_recipe
        @new_recipe ||= current_api_user.recipes.new(recipe_params)
      end

      def recipes
        @recipes ||= current_api_user.recipes.active
      end

    end
  end
end
