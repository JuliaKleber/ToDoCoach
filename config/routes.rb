Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: 'users/sessions'
  }
  root to: 'pages#home'
  resources :tasks do
    collection do
      get :todays_tasks, as: 'todays'
    end
  end
end
