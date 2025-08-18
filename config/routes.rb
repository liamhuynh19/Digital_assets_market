require "sidekiq/web"


Rails.application.routes.draw do
  # authenticate :user, lambda { |u| u.admin? } do
  mount Sidekiq::Web => "/admin/sidekiq"
  # end

  devise_for :users
  resources :products do
    member do
      get :download, to: "products#download", as: :download
    end
    resources :reviews
  end
  resources :categories
  resources :orders, only: [ :index, :show, :create ] do
    patch "mark_as_paid", to: "orders#mark_as_paid", as: :mark_as_paid
    patch "cancel", to: "orders#cancel", as: :cancel
    resources :order_items, only: [ :create, :update, :destroy ]
  end

  get "profile", to: "users#profile", as: :user_profile
  patch "profile", to: "users#update_profile", as: :update_user_profile
  get "purchased_products", to: "products#purchased", as: :purchased_products
  resource :seller_application, only: [ :show, :new, :create, :edit, :update ]

  get "cart", to: "carts#show", as: :cart

  resources :carts, only: [] do
    post "add/:product_id", to: "carts#add_item", as: :add_to_cart
    delete "remove_item/:id", to: "carts#remove_item", as: :remove_from_cart
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

  namespace :api do
    namespace :v1 do
      devise_scope :user do
        post "login", to: "sessions#create"
      end
      resources :products, only: [ :index, :show ]
      resources :orders, only: [ :create, :index, :show ] do
        member do
          patch "mark_as_paid", to: "orders#mark_as_paid", as: :mark_as_paid
        end
      end
    end
  end

  namespace :admin do
    root "users#index"
    get "dashboard", to: "dashboard#index"
    get "report", to: "reports#show"
    resources :products do
      member do
        post :publish, to: "products#publish", as: :publish
      end
      collection do
        post :bulk_import
      end
    end
    resources :users
    resources :categories
    resources :seller_applications do
      member do
        patch :approve
        patch :reject
      end
    end
    resources :orders do
      member do
        resources :order_items, only: [ :create, :update, :destroy ]
      end
    end
    resources :products do
      resources :reviews, only: [ :index ], controller: "reviews"
    end
    resources :reviews, only: [ :index, :show, :edit, :update, :destroy ]
  end

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "products#index"
end
