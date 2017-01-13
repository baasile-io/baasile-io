require 'sidekiq/web'

#class Subdomain
#  def self.matches?(request)
#    (request.subdomain.present? && request.subdomain != 'www' && request.subdomain.match(/[a-z]+/))
#  end
#end

Rails.application.routes.draw do

  devise_for :users

  # Background jobs
  authenticate :user, lambda { |u| u.has_role?(:superadmin) } do
    mount Sidekiq::Web => '/sidekiq'
  end

  root to: "pages#root"

  post '/switch', to: 'application#switch_service'

  resources :services do
    member do
      post :activate
      post :deactivate
      get :admin_board
      post :set_right
      post :unset_right
    end
  end



  namespace :back_office do
    get '/', to: 'dashboards#index'
    resources :dashboards


    get '/permissions/list_proxies_routes', to: 'permissions#list_proxies_routes'
    get '/permissions/list_services', to: 'permissions#list_services'
    post '/permissions/set_right_proxy', to: 'permissions#set_right_proxy'
    post '/permissions/unset_right_proxy', to: 'permissions#unset_right_proxy'
    post '/permissions/set_right_route', to: 'permissions#set_right_route'
    post '/permissions/unset_right_route', to: 'permissions#unset_right_route'


=begin
    resources :services do

      resources :permissions do
          get :list_proxies_routes
          post :set_right_proxy
          post :unset_right_proxy
          post :set_right_route
          post :unset_right_route
      end

    end
=end
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
      scope '/:current_subdomain' do
        resources :services, only: :index
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
