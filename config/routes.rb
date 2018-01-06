Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :logs
  resources :labs, only: [:index]
  get "labs/setup", to: "labs#setup"
  get "labs/:title", to: "labs#show"
end
