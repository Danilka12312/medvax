Rails.application.routes.draw do
  resources :vaccines
  resources :personals
  root 'pages#home'

  resources :personals do
    resources :vaccinations, only: [:create, :destroy]
  end

  resources :vaccinations, only: [:index]
end