Rails.application.routes.draw do
  devise_for :users
  root to: 'tasks#todays_tasks'
  resources :tasks do
    collection do
      get :todays_tasks, as: 'todays'
    end
  end
end
