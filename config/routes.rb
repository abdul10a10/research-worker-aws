Rails.application.routes.draw do
  resources :responses
  resources :answers
  resources :questions
  resources :question_types
  resources :question_categories
  resources :notifications
 # devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  # resources :users
  # resources :users, :path => "getuser"
  # resources :sessions, only: [:create, :destroy]

  get 'about_you/:user_id', to: 'question_categories#about_you'
  get 'users/', to: 'users#index'
  get 'getuserinfo/:id', to: 'users#show'
  get 'participantlist', to: 'users#participant_list'
  get 'researcherlist', to: 'users#researcher_list'
  get 'welcome/:confirmation_token', to: 'users#welcome'

  post 'users', to: 'users#create'
  post 'sharerefferalcode', to: 'users#share_referral_code'

  put 'updateuserinfo/:id', to: 'users#update'
  put 'activateuser/:id', to: 'users#activate'
  put 'deactivateuser/:id', to: 'users#deactivate'
  delete 'deleteuser/:id', to: 'users#destroy'


  devise_for :users, controllers: {
      sessions: 'users/sessions',
      passwords: 'users/passwords',
      registrations: 'users/registrations',
  }

  get 'forgetpassword', to: 'password#new'
  post 'password/forgot', to: 'password#forgot'
  post 'password/reset', to: 'password#reset'
  post 'password/change', to: 'password#change_password'
  post 'admin/login', to: 'sessions#admin_login'
  get 'category_question/:question_category', to: 'questions#category_question'
  get 'question_answer/:id', to: 'answers#question_answer'
end
