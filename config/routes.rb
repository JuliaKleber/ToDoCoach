Rails.application.routes.draw do
  require "sidekiq/web"
  authenticate :user, ->(user) { user.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end
  devise_for :users
  root to: 'pages#home'
  get 'pages/reminder', to: 'pages#reminder'
  resources :tasks do
    collection do
      get :todays_tasks, as: 'todays'
    end
    member do
      patch :toggle_completed
      get :dates_tasks, as: 'dates'
      get :message
    end
  end
end
