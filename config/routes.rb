Rails.application.routes.draw do
  devise_for :users

  root to: "pages#root"

  resources :services do
    member do
      post :unlock
    end
  end

  namespace :dashboard do
    scope "/(:tenant)" do
      get '/', to: 'dashboards#index'
      resource :dashboards, except: [:index]
    end
  end
end
