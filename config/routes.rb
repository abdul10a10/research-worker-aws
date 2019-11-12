Rails.application.routes.draw do
  resources :transactions
  resources :terms_of_uses

  resources :messages
  get 'sent_mails/:id', to: 'messages#sent_mails'
  get 'recieved_mails/:id', to: 'messages#recieved_mails'
  get 'archive_mails/:id', to: 'messages#archive_mails'
  put 'archive_message/:id', to: 'messages#archive_message'
  delete 'delete_message/:id', to: 'messages#delete_message'

  resources :eligible_candidates
  get 'attempt_study/:study_id', to: 'eligible_candidates#attempt_study'
  get 'seen_study/:study_id', to: 'eligible_candidates#seen_study'
  post 'submit_study', to: 'eligible_candidates#submit_study'
  get 'accept_study_submission/:study_id/:user_id', to: 'eligible_candidates#accept_study_submission'
  post 'reject_study_submission/:study_id/:user_id', to: 'eligible_candidates#reject_study_submission'
  get 'participant_study_submission/:user_id', to: 'eligible_candidates#participant_study_submission'
  get 'total_submission_list/:user_id', to: 'eligible_candidates#total_submission_list'
  get 'total_attempt_list/:user_id', to: 'eligible_candidates#total_attempt_list'
  get 'accepted_study_list/:user_id', to: 'eligible_candidates#accepted_study_list'
  get 'rejected_study_list/:user_id', to: 'eligible_candidates#rejected_study_list'

  resources :privacy_policies
  get 'user_policies', to: 'privacy_policies#user_policies'

  resources :terms_and_conditions
  get 'user_terms', to: 'terms_and_conditions#user_terms'

  resources :question_types

  resources :audiences
  put 'delete_audience/:study_id/:question_id', to: 'audiences#delete_audience'

  resources :studies
  post 'add_description', to: 'studies#add_description'
  
  get 'unpublished_studies/:user_id', to: 'studies#unpublished_studies'
  get 'active_studies/:user_id', to: 'studies#active_studies'
  get 'completed_studies/:user_id', to: 'studies#completed_studies'
  get 'rejected_studies/:user_id', to: 'studies#rejected_studies'
  get 'participant_active_study_list/:user_id', to: 'studies#participant_active_study_list'
  get 'track_active_study_list', to: 'studies#track_active_study_list'
  get 'new_study', to: 'studies#new_study'

  get 'study_detail/:id', to: 'studies#study_detail'
  get 'participant_active_study_detail/:id', to: 'studies#participant_active_study_detail'
  get 'researcher_active_study_detail/:id', to: 'studies#researcher_active_study_detail'
  get 'admin_active_study_detail/:id', to: 'studies#admin_active_study_detail'
  get 'active_candidate_list/:id', to: 'studies#active_candidate_list'
  get 'submitted_candidate_list/:id', to: 'studies#submitted_candidate_list'
  get 'accepted_candidate_list/:id', to: 'studies#accepted_candidate_list'
  get 'paid_candidate_list/:id', to: 'studies#paid_candidate_list'
  get 'researcher_unique_id/:id', to: 'studies#researcher_unique_id'
  get 'republish/:id', to: 'studies#republish'

  get 'total_studies', to:  'studies#total_studies'
  get 'admin_new_study_list', to: 'studies#admin_new_study_list'
  get 'admin_complete_study_list', to: 'studies#admin_complete_study_list'
  get 'admin_active_study_list', to: 'studies#admin_active_study_list'
  get 'admin_inactive_study_list', to: 'studies#admin_inactive_study_list'

  put 'publish_study/:id', to:  'studies#publish_study'
  put 'complete_study/:id', to:  'studies#complete_study'
  put 'pay_for_study/:id', to:  'studies#pay_for_study'
  post 'activate_study/:id', to:  'studies#activate_study'
  post 'reject_study/:id', to:  'studies#reject_study'

  resources :responses 
  delete 'delete_response/:question_id', to: 'responses#delete_response'
  get 'user_response/:id', to: 'responses#user_response'
 
  resources :answers
  get 'question_answer/:id', to: 'answers#question_answer'

  resources :questions
  get 'category_question/:question_category_id', to: 'questions#category_question'
  get 'audience_question/:question_category_id/:study_id', to: 'questions#audience_question'
  get 'question_list/:question_category_id', to: 'questions#question_list'
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
  get '/participantinfo/:id', to: 'users#participant_info'
  get 'dashboard', to: 'users#dashboard'
  get 'researcheroverview/:id', to: 'users#researcher_overview'
  get 'participantoverview/:id', to: 'users#participant_overview'
  get 'participantlist', to: 'users#participant_list'
  get 'researcherlist', to: 'users#researcher_list'
  get 'welcome/:confirmation_token', to: 'users#welcome'
  post 'users', to: 'users#create'
  post 'share_referral_code', to: 'users#share_referral_code'
  put 'updateuserinfo/:id', to: 'users#update'
  put 'activateuser/:id', to: 'users#activate'
  put 'deactivateuser/:id', to: 'users#deactivateuser'
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
  post 'check_password', to: 'password#check_password'

  # post 'admin/login', to: 'sessions#admin_login'

  get 'evai_method', to: 'studies#evai_method'
end
