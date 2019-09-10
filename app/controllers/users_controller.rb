class UsersController < ApplicationController
  def index
    @users = User.all
    render json: @users, status: :ok
  end

  def create
    @user = User.new(user_params)
    if @user.save
      @user.generate_email_confirmation_token!
      UserMailer.with(user: @user).welcome_email.deliver_later
      @message = "user-registered"
      @responce = {
          user: @user,
          message: @message,
          status: :created,
      }
      render json: @responce, status: :created
    else
      @message = "already-exists"
      @status = "422"
      @responce = {
          message: @message,
          status: :unprocessable_entity,
      }
      # head(:unprocessable_entity)
      render json: @responce, status: :unprocessable_entity
    end
    # if @user.save
    #   render json: @user, status: :created
    # else
    #   head(:unprocessable_entity)
    # end


  end
  def destroy
    @user = User.find(params[:id])
    if @user.destroy
      @message = "user has been deleted"
      render json: {message: @message}, status: :ok
    else
      head(:unprocessable_entity)
    end
  end

  def show
    # user = User.find(params[:id])

    if  User.where(:id => params[:id]).present?
      user = User.find(params[:id])
      render json: user, status: :found
    else
      @message = "user not found"
      render json: {message: @message}, status: :not_found
    end
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      @message = "user-updated"
      render json: {message: @message}, status: :ok
    else
      head(:unprocessable_entity)
    end
  end

  def activate
    if User.where(:id => params[:id]).present?
      @user = User.find(params[:id])
      @user.status = "active"
      @user.save
      @message = "user-activated"
      render json: {message: @message}, status: :ok
    else
      head(:unprocessable_entity)
    end
  end

  def deactivate
    if User.where(:id => params[:id]).present?
      @user = User.find(params[:id])
      @user.status = "deactive"
      @user.save
      @message = "user-deactivated"
      render json: {message: @message}, status: :ok
    else
      @message = "User-not-found"
      render json: {message: @message}, status: :not_found
    end
  end

  def welcome
    if User.where(:confirmation_token => params[:confirmation_token]).present?

      @user = User.find_by(:confirmation_token => params[:confirmation_token])
      if @user.present? && @user.email_confirmation_valid?
        UserMailer.with(user: @user).user_registration_admin_email.deliver_later
        @user.status = "deactive"
        @user.verification_status = "1"
        @user.save
        @user.generate_referral_code!
        @message = "user-activated"
        render json: {message: @message}, status: :ok
      else
        @message = "Link-expired"
        render json: {message: @message}, status: :ok
      end
      # user.generate_refer_code!
    else
      head(:unprocessable_entity)
    end
  end

  private

  def user_params
    params.permit(:email, :password, :first_name, :last_name, :country, :user_type, :university, :university_email, :department, :specialisation, :job_type, :referral_code)
  end
end
