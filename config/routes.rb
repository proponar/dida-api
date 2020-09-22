Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  namespace :api do
    resources :entries
    resources :locations do
      collection do
        get 'search'
        get 'search/:id', to: 'locations#search'
      end
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
