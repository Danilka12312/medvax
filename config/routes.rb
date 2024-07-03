Rails.application.routes.draw do
  resources :personals
  root 'pages#home'
end