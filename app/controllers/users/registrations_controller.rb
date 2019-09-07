# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  def new
    super
  end

  # POST /resource
  def create
    @user = User.new(configure_sign_up_params)
    if @user.save
      @message = "user-registered"
      @responce = {
          status: :created,
          user: @user,
          message: @message
      }
      render json: @responce, status: :created
    else
      @message = "Email already exist"
      @status = "422"
      @responce = {
          status: @status,
          message: @message
      }
      # head(:unprocessable_entity)
      render json: @responce, status: :unprocessable_entity
    end

  end

  # GET /resource/edit
  def edit
    super
  end

  # PUT /resource
  def update
    super
  end

  # DELETE /resource
  def destroy
    @user = User.find(params[:id])
    if @user.destroy
      head(:ok)
    else
      head(:unprocessable_entity)
    end
  end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  def cancel
    super
  end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    params.permit(:email, :password, :first_name, :last_name, :country, :user_type, :university, :university_email, :department, :specialisation, :job_type, :referral_code)
    # devise_parameter_sanitizer.permit(:sign_up, keys: [:email, :password, :first_name, :last_name, :country, :user_type, :university, :university_email, :department, :specialisation, :job_type, :referral_code])
  end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  end

  # The path used after sign up.
  def after_sign_up_path_for(resource)
    super(resource)
  end

  # The path used after sign up for inactive accounts.
  def after_inactive_sign_up_path_for(resource)
    super(resource)
  end
end
