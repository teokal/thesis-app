Rails.application.routes.draw do

  devise_for :users

  namespace :api do
    api version: 1, module: 'v1' do
      get 'test', to: 'api#test'
      get 'logs_per_action', to: 'api#logs_per_action'
      get 'course', to: 'course#get'
      get 'user', to: 'user#get'

    end
  end

  root 'application#index', as: :home_page
  get '/user', to: 'user#index'

  get '/logs', to: 'es#show', via: :get, as: :logs_page

  get '/fabulous', to: 'es#show_action', via: :get, as: :fabulous_page

  get '/courses', to: 'course#index'
  get '/courses/:id', to: 'course#show'
  get '/courses/:id/moodle', to: 'course#show_moodle'

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
