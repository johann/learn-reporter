Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :logs
  resources :labs, only: [:index, :show, :create, :update]
  post "labs/:title/run", to: "labs#run"
  get "labs/setup", to: "labs#setup"

end
