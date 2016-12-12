require 'sidekiq/web'

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

  namespace :dashboard do
    scope "/(:tenant)" do
      get '/', to: 'dashboards#index'
      resource :dashboards, except: [:index]
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
