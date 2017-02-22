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

  root to: "pages#root"
  get '/service_book', to: "pages#service_book"
  get '/profile', to: 'users#profile'

  resources :contracts

  resources :companies do
    resources :contracts
    member do
      get :clients
      get :startups
      get :admin_list
      get :add_admin
      post :unset_admin
      post :set_admin
    end
  end

  resources :documentations
  
  resources :services do
    resources :contracts
    member do
      post :public_set
      post :public_unset
      post :activate
      post :deactivate
      post :set_right
      post :unset_right
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
    end
  end

  get 'back_office', to: 'back_office#index'
  namespace :back_office do
    resources :users do
      member do
        get :permissions
        put :toggle_is_active
        put :toggle_role
        put :toggle_object_role
      end
    end
    resources :documentations
  end

  namespace :api do
    scope "/oauth" do
      post 'token' => 'authentication#authenticate'
    end

    namespace :v1 do
      resources :services, only: :index
      scope '/:current_subdomain' do
        resources :proxies do
          resources :routes, only: [:index, :show] do
            member do
              match 'request' => 'routes#process_request', as: 'standard_request', via: Route::ALLOWED_METHODS.map do |el| el.downcase.to_sym end
              match 'request/*follow_url' => 'routes#process_request', as: 'special_request', via: Route::ALLOWED_METHODS.map do |el| el.downcase.to_sym end
            end
          end
        end
      end
    end
  end
end
