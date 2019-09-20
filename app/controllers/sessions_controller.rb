class SessionsController < ApplicationController
  def create
    user = User.where(email: params[:email]).first

    if user&.valid_password?(params[:password])
      render json: user.as_json(only: [:id, :email, :authentication_token]), status: :created
    else
      head(:unauthorized)
    end
  end

  def admin_login
    user = User.find_by_email(configure_sign_in_params[:email])

    if user && user.valid_password?(configure_sign_in_params[:password])
      @message = "user-logged-in"
      @expires_in = 3600
      @current_user = user.as_json(only: [:id, :email, :authentication_token])
      render json: {user: @current_user, message: @message, expires_in: @expires_in}, status: :created
    else
      @error = "{ 'email or password is invalid"
      @message = "login failed"
      render json: { errors: @error, message: @message }, status: :ok
    end
  end

  def destroy

  end
end