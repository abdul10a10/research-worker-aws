Rails.application.routes.draw do
  resources :privacy_policies
  resources :terms_and_conditions

  resources :studies
  post 'add_description', to: 'studies#add_description'

  resources :responses 
  post 'delete_response', to: 'responses#delete_response'
 
  resources :answers
  get 'question_answer/:id', to: 'answers#question_answer'

  resources :questions
  get 'category_question/:question_category', to: 'questions#category_question'
  get 'question_list/:question_category', to: 'questions#question_list'
  post 'delete_question/:id', to: 'questions#delete_question'

  resources :question_types

  resources :question_categories
  get 'about_you/:user_id', to: 'question_categories#about_you'

  resources :notifications
  get 'change_seen_status/:id', to: 'notifications#change_seen_status'
  get 'change_status/:user_id', to: 'notifications#change_status'
  get 'user_notification/:user_id', to: 'notifications#user_notification'

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

  # post 'admin/login', to: 'sessions#admin_login'
end
