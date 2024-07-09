Rails.application.routes.draw do
  get 'reports/index'
  resources :vaccines
  resources :personals
  root 'pages#home'
  get 'filter_schedules', to: 'vaccination_schedules#filter_schedules'
  get 'reports/generate_vaccine_order_report', to: 'reports#generate_vaccine_order_report'
  get 'reports/generate_employee_vaccine_report', to: 'reports#generate_employee_vaccine_report'

  resources :personals do
    resources :vaccinations, only: [:create, :destroy]
  end

  resources :vaccinations, only: [:index]

  resources :vaccination_schedules do
    collection do
      get 'calendar'
      get 'new_schedule_for_period'
      post 'create_schedule_for_period'
      get 'show_day'
      post :generate_automatic_schedules
    end
  end

   post 'auto_schedules/generate', to: 'auto_schedules#generate', as: 'generate_auto_schedules'
  get 'auto_schedules/generate', to: 'auto_schedules#generate' # Добавляем GET маршрут здесь

  resources :reports do
    collection do
      get :generate_vaccine_order_report, defaults: { format: :pdf }
      get :generate_employee_vaccine_report, defaults: { format: :pdf }
    end
  end

  resources :rooms
end
