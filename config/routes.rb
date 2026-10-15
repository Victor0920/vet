Rails.application.routes.draw do
  resource :session
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  root "pages#home"

  resources :messages, only: [ :create ]
  resources :conversations
  resources :customers do
    resources :pets, except: :index do
      resources :weights, only: %i[ new create destroy ], module: :pets
    end
  end
  resources :pets, only: :index

  resource :profile, only: %i[ show update ]
  resources :feedbacks, path: "help", only: %i[ index create ]
  resources :appointments

  scope "products" do
    resources :product_categories, path: "categories"
  end
  resources :products, except: :destroy do
    resource :archive, only: %i[ create destroy ], module: :products
  end

  scope "services" do
    resources :service_categories, path: "categories"
  end
  resources :services, except: :destroy do
    resource :archive, only: %i[ create destroy ], module: :services
  end

  resources :invoices do
    resource :email, only: %i[ new create ], module: :invoices
    resources :rectifications, only: %i[ new create ], module: :invoices
  end

  post "/conversations/:id/messages", to: "conversations#create_message"

  scope "settings" do
    resource :enterprise, only: %i[ show edit update ]
    resources :employees, path: "employees", except: :destroy
    resources :stores, path: "stores" do
      resources :rooms, only: %i[ new create edit update ]
      resources :opening_hours, path: "opening-hours", only: %i[ new create edit update destroy ]
    end
    resource :invoice_settings, path: "invoicing", only: %i[ show edit update ] do
      get :preview
    end
    resource :access, only: %i[ show edit update ], controller: :access
    resource :calendar_settings, path: "calendar", only: %i[ show edit update ]
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

  namespace :developer do
    resources :feedbacks, path: "feedback", only: %i[ index show update ]
  end
end
