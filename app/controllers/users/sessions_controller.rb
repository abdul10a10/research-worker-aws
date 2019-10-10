# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  skip_before_action :verify_authenticity_token
  before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  def new
    super
    
  end

  # POST /resource/sign_in
  def create

    user = User.find_by_email(configure_sign_in_params[:email])

    if user && user.valid_password?(configure_sign_in_params[:password])

      if (user.verification_status == "1")

        if (user.status == "active")
          @current_user = user.as_json(only: [:id, :email, :authentication_token])
          @token = JsonWebToken.encode(user_id: user.id)
          @message = "user-logged-in"
          @expires_in = 3600
          render json: {user: @current_user, message: @message, expires_in: @expires_in, Token: @token}, status: :created
        else
          @message = "waiting for admin approval"
        render json: { message: @message  }, status: :ok
        end
        
      else
        user.generate_email_confirmation_token!
        @message = "user-not-verified"
        render json: { message: @message  }, status: :ok
      end
      
    else
      @message = "login-failed"
      render json: { message: @message  }, status: :ok
    end
  end

  # DELETE /resource/sign_out
  def destroy
    super
  end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_in_params
    params.permit(:email, :password)
  end

end
