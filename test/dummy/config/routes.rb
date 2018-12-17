Rails.application.routes.draw do
  resources :users, except: [:show]
end
