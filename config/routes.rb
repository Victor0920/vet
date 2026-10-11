Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  root "pages#home"


  resources :messages, only: [ :index, :show, :create ]
  # get "/messages", to: "messages#index"
  # post "/messages", to: "messages#create"
  # get "/messages/:id", to: "messages#show"

  # get "/conversations", to: "conversations#index"
  # get "/conversations/:id", to: "conversations#show"
  resources :conversations
  resources :customers do
    resources :pets
  end

  resource :profile, only: %i[ show update ]
  resources :appointments

  scope "products" do
    resources :product_categories, path: "categories"
  end
  resources :products

  scope "services" do
    resources :service_categories, path: "categories"
  end
  resources :services

  resources :invoices do
    resource :email, only: %i[ new create ], module: :invoices
    resources :rectifications, only: %i[ new create ], module: :invoices
  end

  post "/conversations/:id/messages", to: "conversations#create_message"

  scope "settings" do
    resource :enterprise, only: %i[ show edit update ]
    resources :employees, path: "employees"
    resources :stores, path: "stores" do
      resources :rooms, only: %i[ new create edit update ]
    end
  end
  resource :settings, only: :show


  namespace :reports do
    resource :sales, only: :show
  end

  get "/auth", to: "auth#index"

  namespace :webhooks do
    get "whatsapp", to: "whatsapp#verify"
    post "whatsapp", to: "whatsapp#receive"
  end
end
