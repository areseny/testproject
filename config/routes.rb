require 'api_constraints'
# require 'sidekiq/web'

Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # mount Sidekiq::Web, at: "/sidekiq"

  namespace :api, defaults: {format: 'json'} do
    scope module: :v1, constraints: ApiConstraints.new(version: 1, default: true) do
      mount_devise_token_auth_for 'User', at: 'auth'

      get 'members_only' => 'pages#members_only'
      get 'anyone' => 'pages#anyone'

      resources :recipes, only: [:index, :show, :create, :update, :destroy] do
        member do
          post 'execute'
        end
      end

      resources :process_chains, only: [:execute, :download_file] do
        member do
          post 'execute'
          get 'retry'
          get 'download_file', as: :download
        end
      end

      resources :process_steps, only: [:download_file] do
        member do
          get 'download_file', as: :download
        end
      end

    end

    # scope module: :v2, constraints: ApiConstraints.new(version: 2, default: true) do
    #
    # end
  end
end
