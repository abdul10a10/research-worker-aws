Rails.application.routes.draw do
  resources :terms_of_uses
  resources :privacy_policies
  get 'user_policies', to: 'privacy_policies#user_policies'

  resources :terms_and_conditions
  get 'user_terms', to: 'terms_and_conditions#user_terms'

  resources :question_types

  resources :audiences
  post 'delete_audience', to: 'audiences#delete_audience'

  resources :studies
  post 'add_description', to: 'studies#add_description'
  
  get 'unpublished_studies/:user_id', to: 'studies#unpublished_studies'
  get 'active_studies/:user_id', to: 'studies#active_studies'
  get 'completed_studies/:user_id', to: 'studies#completed_studies'
  get 'rejected_studies/:user_id', to: 'studies#rejected_studies'
  get 'participant_active_study_list/:user_id', to: 'studies#participant_active_study_list'

  get 'study_detail/:id', to: 'studies#study_detail'
  get 'active_study_detail/:id', to: 'studies#active_study_detail'
  
  get 'total_studies', to:  'studies#total_studies'
  get 'admin_new_study_list', to: 'studies#admin_new_study_list'
  get 'admin_complete_study_list', to: 'studies#admin_complete_study_list'
  get 'admin_active_study_list', to: 'studies#admin_active_study_list'
  get 'admin_inactive_study_list', to: 'studies#admin_inactive_study_list'

  put 'publish_study/:id', to:  'studies#publish_study'
  put 'complete_study/:id', to:  'studies#complete_study'
  post 'activate_study/:id', to:  'studies#activate_study'
  post 'reject_study/:id', to:  'studies#reject_study'

  resources :responses 
  delete 'delete_response/:question_id', to: 'responses#delete_response'
  get 'user_response/:id', to: 'responses#user_response'
 
  resources :answers
  get 'question_answer/:id', to: 'answers#question_answer'

  resources :questions
  get 'category_question/:question_category', to: 'questions#category_question'
  get 'question_list/:question_category', to: 'questions#question_list'
  post 'delete_question/:id', to: 'questions#delete_question'

  resources :question_categories
  get 'about_you', to: 'question_categories#about_you'
  delete 'delete_question_category/:id', to: 'question_categories#delete_question_category'

  resources :notifications
  get 'change_seen_status/:id', to: 'notifications#change_seen_status'
  get 'change_status/:user_id', to: 'notifications#change_status'
  get 'user_notification/:user_id', to: 'notifications#user_notification'

  get 'users/', to: 'users#index'
  get 'getuserinfo/:id', to: 'users#show'
  get '/participantinfo/:id', to: 'users#participantInfo'
  get 'dashboard', to: 'users#dashboard'
  get 'researcheroverview/:id', to: 'users#researcheroverview'
  get 'participantoverview/:id', to: 'users#participantoverview'
  get 'participantlist', to: 'users#participant_list'
  get 'researcherlist', to: 'users#researcher_list'
  get 'welcome/:confirmation_token', to: 'users#welcome'
  post 'users', to: 'users#create'
  post 'sharerefferalcode', to: 'users#share_referral_code'
  put 'updateuserinfo/:id', to: 'users#update'
  put 'activateuser/:id', to: 'users#activate'
  put 'deactivateuser/:id', to: 'users#deactivate'
  delete 'deleteuser/:id', to: 'users#destroy'
  get 'reports', to: 'users#reports'


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
