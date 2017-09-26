module Api
  module V1
    class RecipeStepPresetsController < ApplicationController
      before_action :authenticate_account!, only: [:create, :update, :destroy]
      before_action :authenticate!, only: [:index, :show]

      respond_to :json

      def create
        new_recipe_step_preset.save!
        render json: new_recipe_step_preset, scope: current_entity, scope_name: :current_entity
      rescue => e
        ap e.message
        ap e.backtrace
        render_error(e)
      end

      def index
        render json: recipes, scope: current_entity, scope_name: :current_entity
      end

      def show
        render json: recipe, scope: current_entity, scope_name: :current_entity
      rescue => e
        ap e.message
        ap e.backtrace
        render_error(e)
      end

      def update
        recipe.update!(update_recipe_params)
        render json: recipe, root: false, scope: current_entity, scope_name: :current_entity
      rescue => e
        ap e.message
        ap e.backtrace
        render_error(e)
      end

      def destroy
        recipe.attempt_to_destroy!(current_entity)
        render json: recipe, root: false, scope: current_entity, scope_name: :current_entity
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

      def recipe_step_preset
        @recipe_step_preset ||= RecipeStepPreset.find(params[:id])
      end

      def new_recipe_step_preset
        @new_recipe_step_preset ||= current_entity.account.recipes.new(recipe_params)
      end

      # def recipes
      #   @recipes ||= Recipe.includes(:recipe_steps, process_chains: :process_steps).available_to_account(current_entity.account.id, current_entity.admin?)
      # end
    end
  end
end