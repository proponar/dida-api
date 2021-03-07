Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  namespace :api do
    resources :entries do
      resources :exemps do
        post 'attach'
        post 'detach'
        get 'coordinates', to: 'exemps#coordinates'
      end
      post 'import'
      get 'tvar_map'
    end
    resources :locations do
      collection do
        get 'search'
        get 'search/:id', to: 'locations#search'
      end
      get 'parts'
    end
    get :auth, to: 'auth#auth'
    resources :sources, only: [:index] do
      collection do
        post 'upload'
        get 'download'
      end
    end
    resources :location_texts, only: [:index]
  end
end
