module Api
  module V1
    class RecipesController < ApplicationController
      before_action :authenticate_account!, only: [:create, :update, :destroy, :favourite, :unfavourite, :favourites]
      before_action :authenticate!, only: [:index, :show, :execute]

      respond_to :json

      def execute
        recipe.ensure_step_installation
        @new_chain = recipe.prepare_for_execution(input_files: input_file_param, account: current_entity.account, execution_parameters: execution_params)
        @new_chain.execute_process!(callback_url: callback_url_param[:callback_url], input_files: [input_file_param].flatten)
      rescue => e
        error = e
        ap e.message
        ap e.backtrace
      ensure
        if @new_chain
          @new_chain.reload
          render json: @new_chain, status: 200
        else
          render_error(error)
        end
      end

      def create
        new_recipe.generate_recipe_steps(recipe_step_params)
        new_recipe.save!
        render json: new_recipe, scope: current_entity, scope_name: :current_entity
      rescue => e
        ap e.message
        ap e.backtrace
        render_error(e)
      end

      def favourite
        recipe.mark_as_favourite!(current_entity.account)
        render json: { favourite: recipe.favourited_by?(current_entity.account) }
      rescue => e
        render_error(e)
      end

      def unfavourite
        recipe.unmark_as_favourite!(current_entity.account)
        render json: { favourite: recipe.favourited_by?(current_entity.account) }
      rescue => e
        render_error(e)
      end

      def index
        render json: recipes, scope: current_entity, scope_name: :current_entity
      end

      def favourites
        render json: favourite_recipes, scope: current_entity, scope_name: :current_entity
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

      def recipe_step_params
        params.require(:recipe).permit(:steps => [], steps_with_positions: [:step_class_name, :position])
      end

      def input_file_param
        params.require(:input_files)
      end

      def execution_params
        params[:execution_parameters] || {}
      end

      def callback_url_param
        params.permit(:callback_url)
      end

      def recipe
        @recipe ||= Recipe.includes(:recipe_steps, {process_chains: :process_steps}).available_to_account(current_entity.account.id, current_entity.admin?).find(params[:id])
      end

      def new_recipe
        @new_recipe ||= current_entity.account.recipes.new(recipe_params)
      end

      def recipes
        @recipes ||= Recipe.includes(:recipe_steps, process_chains: :process_steps).available_to_account(current_entity.account.id, current_entity.admin?)
      end

      def favourite_recipes
        @recipes ||= Recipe.includes(:recipe_steps, process_chains: :process_steps).available_to_account(current_entity.account.id, current_entity.admin?).favourites(current_entity.account.id, current_entity.admin?)
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
