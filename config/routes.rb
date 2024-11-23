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
  resources :products, except: [:destroy] do
    member do
      get :price
    end
  end

  resources :suppliers, except: [:destroy]
  resources :customers, except: [:destroy]
  resources :purchases
  resources :sales, except: [:destroy]

  # Rutas de salud y PWA
  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Ruta raíz
  root to: "pages#home"
  get "dashboard", to: "pages#dashboard", as: :dashboard
end
