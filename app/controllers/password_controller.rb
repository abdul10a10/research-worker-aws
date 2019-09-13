class PasswordController < ApplicationController
  def new

  end
  def forgot
    if params[:email].blank? # check if email is present
      @error = "Email not present"
      return render json: {error: @error}, status: :not_found
    end

    user = User.find_by(email: params[:email]) # if present find user by email

    if user.present?
      user.generate_password_token! #generate pass token
      # SEND EMAIL HERE

      ForgetPasswordMailer.with(user: user).forget_password_email.deliver_later

      @message = "Confirmation email has been sent"
      render json: {message: @message}, status: :ok
    else
      @error = "Email address not found. Please check and try again."
      render json: {error: @error}, status: :not_found
    end


  end

  def reset
    token = params[:token].to_s

    if params[:email].blank?
      @error = "Token not present"
      return render json: {error: @error}
    end

    user = User.find_by(reset_password_token: token)

    if user.present? && user.password_token_valid?
      if user.reset_password!(params[:password])
        ForgetPasswordMailer.with(user: user).password_change_email.deliver_later
        @message = "Password-changed"
        render json: {message: @message}, status: :ok
      else
      render json: {error: user.errors.full_messages}, status: :unprocessable_entity
      end
    else
      @error = "[’Link not valid or expired. Try generating a new link.’]"
    render json: {error:  @error}, status: :not_found
    end
  end

  def change_password
    # @id = params[:id]
    @currentpassword = params[:currentpassword]
    @newpassword = params[:newpassword]
    @user = User.find_by(id: params[:id])
    if @user.present?
      if @user && @user.valid_password?(@currentpassword)
        @user.password = @newpassword
        @user.save
        @message = "Password-changed"
        render json: {message: @message}, status: :ok
      else
        @message = "Password-mismatch"
        render json: {user: @user,message: @message}, status: :not_found
      end
    else
      @message = "user-not-found"
      render json: {message: @message}, status: :not_found
    end
  end
end