Rails.application.routes.draw do
  namespace :api do
    api version: 1, module: "v1" do
      post "sign_in", to: "user#sign_in"

      get "test", to: "api#test"
      get "logs_per_action", to: "api#logs_per_action"

      get "user", to: "user#info"

      get "dashboard", to: "user#statistics"

      get "courses", to: "user#courses"
      get "courses/notes", to: "note#notes"

      get "courses/logs", to: "course#get_logs"
      post "courses/logs", to: "course#get_logs"
      get "courses/contents", to: "course#get_course_contents"
      get "courses/custom_categories_graph", to: "course#get_custom_categories_graph"
      get "courses/enrolled_users", to: "course#get_enrolled_users"
      get "courses/modules", to: "course#get_course_modules"
      get "courses/risk_analysis", to: "course#get_risk_analysis"
      post "send_message", to: "user#send_message"

      get "courses/categories", to: "course_category#index"
      post "courses/categories", to: "course_category#create"
      delete "courses/categories", to: "course_category#delete"

      get "courses/initialized_course", to: "course#initialized_course"
      get "courses/activities", to: "user#custom_activities_index"
      post "courses/activities", to: "user#custom_activities_update"

      get "courses/categories_parameters", to: "course#parameters_index"
      post "courses/categories_parameters", to: "course#parameters_update"

      get "notifications", to: "notification#notifications"

      get "notes", to: "note#notes"

      get "events", to: "event#get_events"
    end
  end

  root "application#index", as: :home_page

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

end
