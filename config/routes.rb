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
    end
  end

  namespace :api do
    #scope "/(:api_version)" do
    resources :services, only: :index
  end

  #constraints Subdomain do
    namespace :back_office do
      get '/', to: 'dashboards#index'
      resources :dashboards

      resources :proxies do
        resources :routes do
          resources :query_parameters
        end
      end
    end

    namespace :api do
      namespace :v1 do
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

    match '/services' => redirect("#{ENV['BAASILE_IO_HOSTNAME']}/%{a}"), via: :all
  #end

  namespace :api do
    #scope "/(:api_version)" do
      scope "/oauth" do
        post 'token' => 'authentication#authenticate'
      end
    #end
  end
end
