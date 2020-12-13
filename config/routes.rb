Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  namespace :api do
    resources :entries do
      resources :exemps do
        post 'attach'
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
  end
end
