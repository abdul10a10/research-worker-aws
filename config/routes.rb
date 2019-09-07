Rails.application.routes.draw do
 # devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  # resources :users
  # resources :users, :path => "getuser"
  # resources :sessions, only: [:create, :destroy]

  get 'users/', to: 'users#index'
  get 'getuserinfo/:id', to: 'users#show'
  post 'users', to: 'users#create'
  put 'updateuserinfo/:id', to: 'users#update'
  put 'activateuser/:id', to: 'users#activate'
  put 'deactivateuser/:id', to: 'users#deactivate'
  delete 'deleteuser/:id', to: 'users#destroy'
  devise_for :users, controllers: {
      sessions: 'users/sessions',
      passwords: 'users/passwords',
      registrations: 'users/registrations',
  }


  post 'password/forgot', to: 'password#forgot'
  post 'password/reset', to: 'password#reset'
  post 'admin/login', to: 'sessions#admin_login'
end
