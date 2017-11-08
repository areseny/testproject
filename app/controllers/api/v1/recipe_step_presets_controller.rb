module Api
  module V1
    class RecipeStepPresetsController < ApplicationController
      # before_action :authenticate_account!, only: [:create, :update, :destroy, :creat_from_process_chain]
      before_action :authenticate!

      respond_to :json

      def create_from_process_step
        process_step = ProcessStep.find(params[:process_step_id])
        process_chain = current_entity.account.process_chains.find(process_step.process_chain_id)
        if process_chain.recipe.available_to_account?(current_entity.account)
          new_recipe_step_preset.execution_parameters = process_step.execution_parameters
          new_recipe_step_preset.recipe_step_id = process_chain.recipe.recipe_steps.find_by_position(process_step.position).id
          new_recipe_step_preset.save!
          render json: new_recipe_step_preset, scope: current_entity, scope_name: :current_entity
        else
          render json: "Recipe not available", status: 404
          return
        end
      rescue => e
        ap e.message
        ap e.backtrace
        render_error(e)
      end

      def create
        if new_recipe_step_preset.recipe_step.recipe.available_to_account?(current_entity.account)
          new_recipe_step_preset.execution_parameters = params[:recipe_step_preset][:execution_parameters]
          # not being picked up automatically?
          new_recipe_step_preset.save!
          render json: new_recipe_step_preset, scope: current_entity, scope_name: :current_entity
        else
          render json: "Recipe not available", status: 404
          return
        end
      rescue => e
        ap e.message
        ap e.backtrace
        render_error(e)
      end

      def index
        recipe_step = RecipeStep.find(params[:recipe_step_id])
        recipe = Recipe.find(recipe_step.recipe_id)
        if recipe.available_to_account?(current_entity.account)
          render json: recipe_step_presets, scope: current_entity, scope_name: :current_entity
        else
          render json: "Recipe not available", status: 404 and return
        end
      end

      def show
        if recipe_step_preset.recipe_step.recipe.available_to_account?(current_entity.account)
          render json: {presets: recipe_step_preset}, scope: current_entity, scope_name: :current_entity
        else
          render json: "Recipe not available", status: 404
        end
      rescue => e
        ap e.message
        ap e.backtrace
        render_error(e)
      end

      def update
        if recipe_step_preset.recipe_step.recipe.available_to_account?(current_entity.account)
          recipe_step_preset.execution_parameters = params[:recipe_step_preset][:execution_parameters]
          recipe_step_preset.update!(recipe_step_preset_params)
          render json: recipe_step_preset, root: false, scope: current_entity, scope_name: :current_entity
        else
          render json: "Recipe not available", status: 404 and return
        end
      rescue => e
        ap e.message
        ap e.backtrace
        render_error(e)
      end

      def destroy
        recipe_step_preset.destroy
        render json: recipe_step_preset, root: false, scope: current_entity, scope_name: :current_entity
      rescue => e
        render_error(e)
      end

      private

      def recipe_step_preset_params
        params.require(:recipe_step_preset).permit(:name, :description, :execution_parameters, :recipe_step_id)
      end

      def recipe_step_preset
        @recipe_step_preset ||= current_entity.account.recipe_step_presets.find(params[:id])
      end

      def recipe_step_presets
        @recipe_step_presets ||= current_entity.account.recipe_step_presets.where(recipe_step_id: params[:recipe_step_id])
      end

      def new_recipe_step_preset
        @new_recipe_step_preset ||= current_entity.account.recipe_step_presets.new(recipe_step_preset_params)
      end
    end
  end
end