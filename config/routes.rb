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

  constraints Subdomain do
    namespace :back_office do
      get '/', to: 'dashboards#index'
      resources :dashboards, except: [:index]

      resources :functionalities do
        member do
          get :configure
          post :save_configuration
        end
      end
    end
  end

  namespace :api do
    scope "/(:api_version)" do
      scope "/oauth" do
        post 'token' => 'authentication#authenticate'
      end
    end
  end
end
