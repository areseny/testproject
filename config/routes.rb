require 'api_constraints'
# require 'sidekiq/web'

Rails.application.routes.draw do

  # mount Sidekiq::Web, at: "/sidekiq"

  namespace :api, defaults: {format: 'json'} do
    scope module: :v1, constraints: ApiConstraints.new(version: 1, default: true) do
      mount_devise_token_auth_for 'User', at: 'auth'

      get 'members_only' => 'pages#members_only'
      get 'anyone' => 'pages#anyone'

      resources :recipes, only: [:index, :show, :create, :update, :destroy] do
        collection do

        end
        member do
          post 'execute'
        end
      end

      resources :conversion_chains, only: [:execute, :download_file] do
        member do
          post 'execute'
          get 'retry'
          get 'download_file', as: :download
        end
      end

      resources :conversion_steps, only: [:download_file] do
        member do
          get 'download_file', as: :download
        end
      end

      resources :organisations, only: [:create, :index]
      resources :memberships, only: [:create] #add update delete
    end

    # scope module: :v2, constraints: ApiConstraints.new(version: 2, default: true) do
    #
    # end
  end


  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
