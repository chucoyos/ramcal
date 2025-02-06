Rails.application.routes.draw do
  resources :payables
  resources :suppliers
  get "reports" => "reports#index", as: :reports
  resources :payments

  resources :invoices do
    member do
      get :download_pdf
    end
  end

  resources :pricings
  resources :services
  get "location", to: "moves#search_locations"
  mount ActionCable.server => "/cable"
  patch "completeds/:id" => "completeds#update"
  resources :notifications do
    resource :completed
  end
  resources :locations
  resources :moves

  resources :eirs
  resources :containers do
    post :create_invoice_container_services, on: :member
  end
  resources :permissions
  resources :roles

  root "pages#index"
  get "videos" => "pages#videos", as: :videos
  get "catalogs" => "pages#catalogs", as: :catalogs
  devise_for :users, controllers: { registrations: "users/registrations", sessions: "users/sessions" }
  get "users/new" => "users#new", as: :new_user
  get "users/:id" => "users#show", as: :user
  get "users" => "users#index", as: :users
  get "users/:id/edit" => "users#edit", as: :edit_user
  patch "users/:id" => "users#update"
  post "staff" => "users#create", as: :members
  delete "staff/:id" => "users#destroy", as: :delete_member

  # temporary routes as solution to the problem of the location_id in the link =====> "locations.:id"
  delete "locations.:id" => "locations#destroy", as: :delete_location
  patch "locations.:id" => "locations#update", as: :update_location
  # end of temporary routes

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # Defines the root path route ("/")
  # root "posts#index"
  # match "*path", to: "application#render_404", via: :all
end
