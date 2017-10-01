Rails.application.routes.draw do

  devise_for :users

  namespace :api do
    api version: 1, module: 'v1' do
      get 'test', to: 'api#test'
      get 'actions', to: 'api#actions'
      get 'logs_per_action', to: 'api#logs_per_action'

      get 'courses', to: 'user#courses'
      get 'courses_statistics', to: 'user#statistics'

      get 'courses/logs', to: 'course#get_logs'
      get 'courses/contents', to: 'course#get_course_contents'
      get 'courses/contents/logs', to: 'course#get_course_contents_logs'
      get 'courses/contents/modules', to: 'course#get_course_modules'
      get 'courses/contents/modules/logs', to: 'course#get_course_modules_logs'

      get 'admin/users/logs', to: 'admin#logs'

    end
  end

  root 'application#index', as: :home_page

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller query_es automatically):
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
