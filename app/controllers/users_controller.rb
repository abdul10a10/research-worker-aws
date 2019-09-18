class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update, :destroy, :activate, :deactivate, :share_referral_code]
  def index
    @users = User.all
    render json: @users, status: :ok
  end

  def participant_list
    @user = User.where(user_type: 'Participant')
    render json: @users, status: :ok
  end

  def researcher_list
    @user = User.where(user_type: 'Researcher')
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
    if @user.destroy
      @message = "user has been deleted"
      render json: {message: @message}, status: :ok
    else
      head(:unprocessable_entity)
    end
  end

  def show
    if  @user.present?
      @message = "user-info"
      render json: {user: @user, message: @message}, status: :ok
    else
      @message = "user-not-found"
      render json: {message: @message}, status: :ok
    end
  end

  def update
    if @user.update_attributes(user_params)
      @message = "user-updated"
      render json: {message: @message}, status: :ok
    else
      head(:unprocessable_entity)
    end
  end

  def activate
    if @user.present?
      @user.status = "active"
      @user.save
      @message = "user-activated"
      render json: {message: @message}, status: :ok
    else
      head(:unprocessable_entity)
    end
  end

  def deactivate
    if @user.present?
      @reason = params[:reason]
      @user.status = "deactive"
      @user.save
      @message = "user-deactivated"
      UserMailer.with(user: @user, reason: @reason).rejection_email.deliver_later
      render json: {message: @message}, status: :ok
    else
      @message = "User-not-found"
      render json: {message: @message}, status: :not_found
    end
  end

  def welcome
    if User.where(confirmation_token: params[:confirmation_token]).present?

      @user = User.find_by(confirmation_token: params[:confirmation_token])
      if @user.present? && @user.email_confirmation_valid?
        if @user.verification_status == "1"
          @message = "already-activated-account"
          render json: {message: @message}, status: :ok
        else
          @user.status = "deactive"
          @user.verification_status = "1"
          @user.save
          @user.generate_referral_code!
          @message = "user-activated"

          UserMailer.with(user: @user).user_registration_admin_email.deliver_later
          @notification = Notification.new
          @notification.notification_type = "Registration"
          @notification.user_id = "0"
          @user_type = @user.user_type
          @notification.message = "New " + @user_type +" has registered"

          if @user.user_type == "Participant"
            @notification.redirect_url = "http://karyonsolutions.com/research_workAdmin_front-end/#/participantlist"
          elsif @user.user_type == "Researcher"
            @notification.redirect_url = "http://karyonsolutions.com/research_workAdmin_front-end/#/researcherlist"
          end
          @notification.save
          render json: {message: @message}, status: :ok
        end

      else
        @message = "Link-expired"
        render json: {message: @message}, status: :ok
      end
      # user.generate_refer_code!
    else
      head(:unprocessable_entity)
    end
  end

  def share_referral_code
    @receiver = params[:email]
    UserMailer.with(user: @user, receiver: @receiver).share_referral_code_email.deliver_later
    @message = "Code-shared"
    render json: {message: @message}, status: :ok

  end
  private

  def user_params
    params.permit(:email, :password, :first_name, :last_name, :country, :user_type, :university, :university_email, :department, :specialisation, :job_type, :referral_code)
  end

  def set_user
    @user = User.find(params[:id])
  end
  end
