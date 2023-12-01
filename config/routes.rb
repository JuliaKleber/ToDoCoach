Rails.application.routes.draw do
  require "sidekiq/web"
  authenticate :user, ->(user) { user.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end
  devise_for :users

  resources :users, except: %i[index new create edit update destroy] do
    member do
      get :feed
      get :connect
      post :build_connection
    end
  end

  root to: 'pages#home'
  get 'pages/reminder', to: 'pages#reminder'
  
  resources :tasks do
    collection do
      get :todays_tasks, as: 'todays'
      get :tasks_without_date
    end
    member do
      patch :toggle_completed
      get :dates_tasks, as: 'dates'
      get :message
    end
  end
end
