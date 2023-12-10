Rails.application.routes.draw do
  require "sidekiq/web"
  authenticate :user, ->(user) { user.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end
  devise_for :users

  root to: 'pages#home'
  get 'pages/reminder', to: 'pages#reminder'

  resources :users, except: %i[index show new create edit update destroy] do
    member do
      get :feed
      get :achievements
      get :congratulate
      get :connect
      post :build_connection
      get :disconnect
      delete :destroy_connection
    end
  end

  resources :tasks do
    collection do
      get :todays_tasks, as: 'todays'
      get :tasks_without_date
    end
    member do
      patch :toggle_completed
      get :dates_tasks, as: 'dates'
      get :message
      get :add_user
    end
  end

  resources :task_invitations, except: %i[index show new create edit update]
end
