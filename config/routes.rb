Rails.application.routes.draw do
  # Rutas de devise
  devise_for :users
  devise_for :employees, path: "employees", path_names: {
    sign_in: "login",
    sign_out: "logout"
  }

  # Recursos y rutas personalizadas para empleados
  resources :employees do
    collection do
      get :profile
      get :edit_password
      patch :update_password
    end
  end

  # Otros recursos
  resources :products, except: [ :destroy ] do
    member do
      get :price
    end
    collection do
      get :search
    end
  end

  resources :suppliers do
    collection do
      get :search
    end
  end
  resources :customers do
    collection do
      get :search
    end
  end
  resources :purchases
  resources :sales, except: [ :destroy ] do
    collection do
      get :search
    end
  end

  # Rutas de salud y PWA
  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Ruta raíz
  root to: "pages#home"
  get "dashboard", to: "pages#dashboard", as: :dashboard
  get "doc_gemini", to: "pages#doc_gemini", as: :doc_gemini
  get "sale_gemini", to: "pages#sale_gemini", as: :sale_gemini

  resources :users do
    collection do
      get :profile
      get :edit_profile
      patch :update_profile
    end
  end

  resources :uploads
  resources :sales_uploads
end
