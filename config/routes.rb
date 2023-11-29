Rails.application.routes.draw do
  devise_for :users
  root to: 'pages#home'
  resources :tasks do
    collection do
      get :todays_tasks, as: 'todays'
    end
    member do
      patch :toggle_completed
      get :dates_tasks, as: 'dates'
    end
  end
end
