require 'api_constraints'
require 'sidekiq/api'
require 'sidekiq/web'

Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  Sidekiq::Web.set :session_secret, Rails.application.secrets[:secret_key_base]

  # authenticate :user, lambda { |u| u.admin? } do
  # authenticate :user do
  mount Sidekiq::Web => '/sidekiq'
  mount HealthMonitor::Engine, at: '/'
  # end

  match "queue-latency" => proc { [200, {"Content-Type" => "text/plain"}, [Sidekiq::Queue.new.latency < 30 ? "OK" : "UHOH" ]] }, via: :get

  namespace :api, defaults: {format: 'json'} do
    scope module: :v1, constraints: ApiConstraints.new(version: 1, default: true) do
      namespace :auth do
        post 'sign_in' => 'authentication#sign_in'
      end
      mount_devise_token_auth_for 'Account', at: 'auth'
      mount_devise_token_auth_for 'Service', at: 'service_auth'

      namespace :admin do
        get 'accounts' => 'accounts#index'
        get 'service_accounts' => 'accounts#service_accounts'
      end

      get 'members_only' => 'pages#members_only'
      get 'anyone' => 'pages#anyone'
      get 'jwt_test' => 'pages#json_web_token_test'

      get 'available_step_classes' => 'step_class#index'
      get 'available_step_gems' => 'step_class#index_by_gems'

      resources :recipes, only: [:index, :show, :create, :update, :destroy] do
        collection do
          get 'favourites'
          get 'index-all'
        end

        member do
          post 'execute'
          get 'favourite'
          get 'unfavourite'
        end
      end

      resources :process_chains, only: [:execute, :download_file] do
        member do
          post 'execute'
          get 'retry'
          get 'download_input_file'
          get 'download_input_zip'
          get 'download_output_file'
          get 'download_output_zip'
        end
      end

      resources :process_steps, only: [:download_file] do
        member do
          get 'download_output_file'
          get 'download_output_zip'
          get 'download_process_log'
        end
      end

      resources :single_step_executions do
        collection do
          post 'create'
        end
        member do
          get 'download_output_file'
          get 'download_output_zip'
          get 'download_process_log'
          get 'download_input_file'
          get 'download_input_zip'
        end
      end

      resources :recipe_steps, only: [] do #ha
        resources :recipe_step_presets, only: [:index]
      end

      resources :recipe_step_presets, only: [:create, :update, :show, :destroy] do
        collection do
          post 'create_from_process_step'
        end
      end

      root 'pages#anyone'
    end

    # scope module: :v2, constraints: ApiConstraints.new(version: 2, default: true) do
    #
    # end
  end

  root 'api/v1/pages#index'
end
