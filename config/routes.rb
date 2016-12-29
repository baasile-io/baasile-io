require 'sidekiq/web'

class Subdomain
  def self.matches?(request)
    (request.subdomain.present? && request.subdomain != 'www' && request.subdomain.match(/[a-z]+/))
  end
end

Rails.application.routes.draw do
  devise_for :users

  # Background jobs
  authenticate :user, lambda { |u| u.has_role?(:superadmin) } do
    mount Sidekiq::Web => '/sidekiq'
  end

  root to: "pages#root"

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

  constraints Subdomain do
    namespace :back_office do
      get '/', to: 'dashboards#index'
      resources :dashboards, except: [:index]

      resources :proxies do
        resources :routes
      end
    end

    namespace :api do
      #scope "/(:api_version)" do
        resources :proxies do
          resources :routes do
            member do
              get '/*url' => 'proxies#show'
            end
          end
        end
      #end
    end
  end

  namespace :api do
    #scope "/(:api_version)" do
      scope "/oauth" do
        post 'token' => 'authentication#authenticate'
      end
    #end
  end
end
