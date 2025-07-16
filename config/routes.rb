Rails.application.routes.draw do
  devise_for :users
  resources :reviews
  resources :products
  resources :posts
  resources :categories
  get "profile", to: "users#profile", as: :user_profile
  patch "profile", to: "users#update_profile", as: :update_user_profile

  get "cart", to: "carts#show", as: :cart

  resources :carts, only: [] do
    post "add/:product_id", to: "carts#add_item", as: :add_to_cart
    delete "remove_product/:product_id", to: "carts#remove_item", as: :remove_from_cart
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  # Reveal health status on /up that returns 20
  # 0 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  as :user do
    get "signin" => "devise/sessions#new"
    post "signin" => "devise/sessions#create"
    delete "signout" => "devise/sessions#destroy"
  end

  namespace :admin do
    root "dashboard#index"
    get "dashboard", to: "dashboard#index"
    resources :products
    resources :users
    resources :categories
  end

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "products#index"
end
