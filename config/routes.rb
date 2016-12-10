Rails.application.routes.draw do
  devise_for :users

  root to: "pages#root"

  resources :services
end
