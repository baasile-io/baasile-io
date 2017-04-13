require 'sidekiq/web'

Rails.application.routes.draw do

  captcha_route
  devise_for :users, path: 'auth', controllers: { sessions: 'users/sessions',
                                                  registrations: 'users/registrations',
                                                  confirmations: 'users/confirmations',
                                                  passwords: 'users/passwords',
                                                  unlocks: 'users/unlocks' }

  # Background jobs
  authenticate :user, lambda { |u| u.has_role?(:superadmin) } do
    mount Sidekiq::Web => '/sidekiq'
  end

  root to: 'pages#root'

  resources :pages, only: [:not_found]
  get '/service_book', to: 'pages#service_book'
  get '/startup/:id', to: 'pages#startup', as: 'startup'
  get '/profile', to: 'users#profile'

  resources :contracts do
    member do
      get :comments
      post :create_comment
      post :validate
      post :reject
      get :prices
      get :select_price
      post :toggle_production
      post :cancel
    end
    resources :prices do
      resources :price_parameters
    end
  end

  resources :documentations

  resources :users

  resources :services do
    resources :contracts do
      member do
        get :comments
        post :create_comment
        post :validate
        post :reject
        get :prices
        get :select_price
        post :toggle_production
        post :cancel
      end
      resources :prices do
        resources :price_parameters
      end
    end
    resources :users do
      member do
        put :toggle_role
        delete :disassociate
      end
      collection do
        post :invite_by_email
        post :invite_by_id
      end
    end
    member do
      post :set_right
      post :unset_right
      get :users
      get :logo
      post :logo
      get '/logo/image', to: 'services#logo_image'
    end

    get '/permissions/list_proxies_routes', to: 'permissions#list_proxies_routes'
    get '/permissions/list_services', to: 'permissions#list_services'
    post '/permissions/set_right_proxy', to: 'permissions#set_right_proxy'
    post '/permissions/unset_right_proxy', to: 'permissions#unset_right_proxy'
    post '/permissions/set_right_route', to: 'permissions#set_right_route'
    post '/permissions/unset_right_route', to: 'permissions#unset_right_route'
    post '/permissions/set_right', to: 'permissions#set_right'
    post '/permissions/unset_right', to: 'permissions#unset_right'

    resources :proxies do
      resources :identifiers
      resources :routes do
        resources :query_parameters
      end
      resources :prices do
        resources :price_parameters do
          post :toogle_activate
        end
        post :toogle_activate
      end
    end
  end

  resources :comments do
    member do
      put :hide
    end
  end

  get 'back_office', to: 'back_office#index'
  namespace :back_office do
    resources :users do
      member do
        get :audit
        get :permissions
        put :toggle_is_active
        put :toggle_role
        put :toggle_object_role
        put :associate
        delete :disassociate
        put :sign_in_as
      end
    end

    resources :services do
      member do
        get :audit
      end
    end

    resources :documentations
    resources :categories
  end

  namespace :api do
    scope "/oauth" do
      post 'token' => 'authentication#authenticate'
    end

    namespace :v1 do
      resources :services, only: :index
      scope '/:current_subdomain' do
        get '/' => 'services#show'
        resources :proxies do
          resources :routes, only: [:index, :show] do
            member do
              match 'request' => 'routes#process_request', as: 'standard_request', via: Route::ALLOWED_METHODS.map do |el| el.downcase.to_sym end
              match 'request/*follow_url' => 'routes#process_request', as: 'special_request', via: Route::ALLOWED_METHODS.map do |el| el.downcase.to_sym end
            end
          end
        end
        resources :contracts
      end
    end

    get "*any", via: :all, to: "api#not_found"
  end

  get "*any", via: :all, to: "pages#not_found"
end
