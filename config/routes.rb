require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :users

  # Background jobs
  authenticate :user, lambda { |u| u.admin? } do
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
end
