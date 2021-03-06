require 'sidekiq/web'

Rails.application.routes.draw do

  namespace :api do
    scope "/oauth" do
      post 'token' => 'authentication#authenticate'
    end

    namespace :v1 do
      get '/' => 'services#root', as: :root
      resources :services, only: :index
      scope '/:current_subdomain' do
        resources :measure_tokens do
          member do
            post :revoke
          end
        end
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

      resources :categories
      resources :appconfigs do
        member do
          post '/update', to: 'appconfigs#update', as: 'update'
          delete '/destroy', to: 'appconfigs#destroy', as: 'destroy'
        end
      end
    end

    match "*any", via: :all, to: "api#not_found"
  end

  captcha_route

  get '/robots.txt' => 'pages#robots'
  get '/logotype/:client_id/(:format)', to: 'pages#startup_logotype', as: :startup_logotype

  scope "/(:locale)", locale: /#{I18n.available_locales.join("|")}/ do

    devise_for :users, path: 'auth', controllers: { sessions: 'users/sessions',
                                                    registrations: 'users/registrations',
                                                    confirmations: 'users/confirmations',
                                                    passwords: 'users/passwords',
                                                    unlocks: 'users/unlocks',
                                                    password_expired: 'users/password_expired' }

    root to: 'pages#root'

    resources :pages, only: [:not_found]
    get '/catalog', to: 'pages#catalog', as: 'catalog'
    get '/catalog/products/:proxy_id', to: 'pages#catalog_product', as: 'catalog_product'
    get '/catalog/search', to: 'pages#catalog_search', as: 'catalog_search'
    get '/catalog/:cat', to: 'pages#category', as: 'catalog_category'
    get '/service_book' => redirect('/catalog')
    get '/startup/:id', to: 'pages#startup', as: 'startup'
    get '/profile', to: 'users#profile'

    resources :contracts do
      member do
        get :error_measurements
        get :error_measurement
        get :comments
        post :create_comment
        post :validate
        post :validate_general_condition
        get :general_condition
        post :reject
        get :prices
        get :select_price
        get :client_bank_details
        get :client_bank_details_selection
        post :select_client_bank_detail
        get :startup_bank_details
        get :startup_bank_details_selection
        post :select_startup_bank_detail
        post :cancel
        get :print_current_month_consumption
        get :audit
        post :reset_free_count_limit
      end
      collection do
        get :catalog
        get :select_client
      end
      resources :prices do
        resources :price_parameters
      end
    end

    resources :bills do
      member do
        get :print
        get :comments
        post :mark_as_paid
        post :mark_platform_contribution_as_paid
      end
    end

    resources :documentations do
      collection do
        get :errors
      end
    end

    resources :users

    resources :tickets do
      collection do
        get :closed
      end
      member do
        post :add_comment
      end
    end

    resources :services do

      resources :bank_details

      resources :contracts do
        member do
          get :error_measurements
          get :error_measurement
          get :comments
          post :create_comment
          post :validate
          post :reject
          post :validate_general_condition
          get :general_condition
          get :prices
          get :select_price
          get :client_bank_details
          get :client_bank_details_selection
          post :select_client_bank_detail
          get :startup_bank_details
          get :startup_bank_details_selection
          post :select_startup_bank_detail
          post :cancel
          get :print_current_month_consumption
          get :audit
          post :reset_free_count_limit
        end
        collection do
          get :catalog
          get :select_client
        end
        resources :prices do
          resources :price_parameters
        end
      end

      resources :bills do
        member do
          get :print
          get :comments
          post :mark_as_paid
          post :mark_platform_contribution_as_paid
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

      resources :error_measurements
      member do
        post :activation_request
        post :set_right
        post :unset_right
        get :users
        get :audit
        get :logo
        post :logo
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
        member do
          get :confirm_destroy
          get :audit
        end
        resources :error_measurements
        resources :identifiers
        resources :routes do
          member do
            get :confirm_destroy
            get :audit
          end
          resources :query_parameters
        end
        resources :prices do
          resources :price_parameters do
            post :toogle_activate
          end
          post :toogle_activate
        end
        namespace :tester do
          resources :requests do
            member do
              get :template
            end
          end

          post '/process_request/:id' => 'process_requests#process_request', as: 'process_request'
          post '/process_template_request/:id' => 'process_requests#process_template_request', as: 'process_template_request'
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
      resources :request_templates do
        member do
          get :duplicate
        end
      end
      resources :error_measurements
      resources :users do
        member do
          get :audit
          get :users
          get :permissions
          put :toggle_is_active
          put :toggle_role
          put :toggle_object_role
          put :associate
          delete :disassociate
          put :sign_in_as
          put :unlock_after_expired
        end
      end

      resources :services do
        member do
          get :audit
          get :users
          delete :disassociate_user
          put :associate_user
          put :toggle_user_role
        end
      end
      resources :tickets do
        collection do
          get :closed
        end
        member do
          post :add_comment
          post :close
          post :open
        end
      end
      resources :bank_details do
        member do
          post :toggle_is_active
          get :audit
        end
      end
      resources :general_conditions
      resources :contracts do
        member do
          get :audit
          get :comments
        end
      end
      resources :bills do
        member do
          get :audit
          get :comments
        end
      end

      resources :documentations
      resources :categories
      resources :appconfigs do
        member do
          post '/update', to: 'appconfigs#update', as: 'update'
          delete '/destroy', to: 'appconfigs#destroy', as: 'destroy'
        end
      end
    end
  end

  # Background jobs
  authenticate :user, lambda { |u| u.has_role?(:superadmin) } do
    mount Sidekiq::Web => '/sidekiq'
  end

  get '/users/sign_in', to: redirect('/auth/sign_in')

  match "/404", via: :all, to: "pages#not_found"
  match "/500", via: :all, to: "pages#internal_server_error"
  match "*any", via: :all, to: "pages#not_found"
end
