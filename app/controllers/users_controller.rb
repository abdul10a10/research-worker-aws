class UsersController < ApplicationController
  # before_action :authorize_request, except: :create
  before_action :set_user, only: [ :update, :destroy, :activate, :deactivate, :share_referral_code]

  def index
    @users = User.all.order(id: :desc)
    render json: {Data: @users, CanEdit: true, CanDelete: false, Status: :ok, message: 'All-users', Token: nil, Success: false}, status: :ok

  end

  def participant_list
    @user = User.where(user_type: 'Participant').order(id: :desc)
    render json: {Data: @user, CanEdit: true, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
  end

  def researcher_list
    @user = User.where(user_type: 'Researcher').order(id: :desc)
    @message = "user-list"
    render json: {Data: @user, CanEdit: true, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
  end


  def create
    @user = User.new(user_params)
    if @user.user_type == 'Participant'
      @validation = @user.validateparamsparticipant!
    else
      @validation = @user.validateparamsresearcher!
    end
    if @validation
      if @user.save
        @user.generate_email_confirmation_token!
        UserMailer.with(user: @user).welcome_email.deliver_later
        @message = "user-registered"
        render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :created
      else
        @message = "already-exists"
        render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
      end
    else
      @message = "fields-not-filled"
      render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
    end
  end


  def destroy
    if @user.destroy
      @message = "user has been deleted"
      render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
    else
      head(:ok)
    end
  end

  def show
    if User.exists?(params[:id])
      @user = User.find_by_id(params[:id])
      @message = "user-info"
      render json: {user: @user, message: @message}, status: :ok
    else
      @message = "user-not-found"
      render json: { message: @message}, status: :ok
    end
  end


  def update
    if @user.update_attributes(user_params)
      @message = "user-updated"
      render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
    else
      head(:ok)
    end
  end

  def activate
    if @user.present?
      @user.status = "active"
      @user.save
      @message = "user-activated"
      render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
    else
      head(:ok)
    end
  end


  def deactivate
    if @user.present?
      @reason = params[:reason]
      @user.status = "deactive"
      @user.save
      @message = "user-deactivated"
      UserMailer.with(user: @user, reason: @reason).rejection_email.deliver_later
      render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
    else
      @message = "User-not-found"
      render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :not_found
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
      head(:ok)
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
    if User.exists?(params[:id])
      @user = User.find(params[:id])
    else
      @message = "User-not-found"
      render json: {message: @message}, status: :ok
    end
  end
end
