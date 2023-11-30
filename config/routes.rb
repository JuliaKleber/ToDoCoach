# require "sidekiq/web"

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
      get :message
    end
  end
  # authenticate :user, ->(user) { user.admin? } do
  #   mount Sidekiq::Web => '/sidekiq'
  # end
end
