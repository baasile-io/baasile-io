require 'sidekiq/web'

Rails.application.routes.draw do

  captcha_route
  devise_for :users

  # Background jobs
  authenticate :user, lambda { |u| u.has_role?(:superadmin) } do
    mount Sidekiq::Web => '/sidekiq'
  end

  root to: "pages#root"

  get '/profile', to: 'users#profile'

  resources :users do
    member do
      post :set_admin
      post :unset_admin
    end
  end

  resources :services do
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
      resources :routes do
        resources :query_parameters
      end
    end
  end

  namespace :api do
    scope "/oauth" do
      post 'token' => 'authentication#authenticate'
    end

    namespace :v1 do
      resources :services, only: :index
      scope '/:current_subdomain' do
        resources :proxies do
          resources :routes, only: [:index] do
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
