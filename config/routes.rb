Rails.application.routes.draw do
  root 'pages#home'

  get '/about', to: 'pages#about'
  get '/contact', to: 'pages#contact'

  devise_for :players

  # other resources like campaigns, memberships, etc.
  resources :campaigns
  resources :sessions
end
