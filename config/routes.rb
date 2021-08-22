Rails.application.routes.draw do
  namespace :api, defaults: { format: :json } do
    resources :cars, only: [:index]
  end
end
