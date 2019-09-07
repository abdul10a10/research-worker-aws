Rails.application.routes.draw do
 # devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :users
  # resources :sessions, only: [:create, :destroy]
  devise_for :users, controllers: {
      sessions: 'users/sessions',
      passwords: 'users/passwords',
      registrations: 'users/registrations',
  }


  post 'password/forgot', to: 'password#forgot'
  post 'password/reset', to: 'password#reset'
  post 'admin/login', to: 'sessions#admin_login'
end
