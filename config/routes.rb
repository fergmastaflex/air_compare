Rails.application.routes.draw do
  resources :comparisons, only: :index
  root to: 'comparisons#index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
