class UsersController < ApplicationController 
  before_action :authorize_request, except: [:create, :destroy, :welcome, :check_email, :check_city_pincode]
  before_action :is_admin, only: [:index, :dashboard, :participant_list, :researcher_list, :deactivateuser, :activate, 
    :researcheroverview, :participantoverview, :reports]
  before_action :set_user, only: [:show,:update_image, :update, :destroy, :activate, :deactivateuser, :participant_overview, :researcher_overview, :participant_info]

  #GET /users
  def index
    @users = User.all.order(id: :desc)
    render json: {Data: @users, CanEdit: true, CanDelete: false, Status: :ok, message: 'All-users', Token: nil, Success: false}, status: :ok
  end

  #GET /dashboard
  def dashboard
    @message = "user-info"
    @notification = Notification.where(user_id: @current_user.id, deleted_at: nil).order(id: :desc)
    render json: {Data: {user: @current_user, notification: @notification}, CanEdit: true, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
  end

  #GET /participantlist
  def participant_list
    @user = User.where(user_type: 'Participant', verification_status: '1').order(id: :desc)
    render json: {Data: @user, CanEdit: true, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
  end

  #GET /researcherlist
  def researcher_list
    @user = User.where(user_type: 'Researcher', verification_status: '1').order(id: :desc)
    @message = "user-list"
    render json: {Data: @user, CanEdit: true, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok   
  end

  #Post /users
  def create
    @user = User.new(user_params)
    if @user.user_type == 'Participant'
      @validation = @user.validateparamsparticipant!
    else
      @validation = @user.validateparamsresearcher!
    end
    if @validation
      if @user.country == "UAE" || @user.country == "United Arab Emirates"
        city = user_params[:city].split.map(&:capitalize).join(' ')
        pincode = user_params[:pincode].split.map(&:capitalize).join(' ')
        if UaePost.where(city: city, po_box_number: pincode).present?
          if @user.save
            @user.generate_email_confirmation_token!
            @user.generate_unique_id!
            MailService.user_welcome_email(@user.id)
            @message = "user-registered"
            render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :created
          else
            @message = "already-exists"
            render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
          end
        else
          @message = "pincode-miss-match"
          render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
        end    
      else
        if @user.save
          @user.generate_email_confirmation_token!
          @user.generate_unique_id!
          MailService.user_welcome_email(@user.id)
          @message = "user-registered"
          render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :created
        else
          @message = "already-exists"
          render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
        end
      end
    else
      @message = "fields-not-filled"
      render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
    end
  end


  def destroy
    Notification.where(user_id: @user.id).delete_all
    EligibleCandidate.where(user_id: @user.id).delete_all
    Response.where(user_id: @user.id).delete_all
    Study.where(user_id: @user.id).delete_all
    @user.destroy
    @message = "user-deleted"
    render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
  end

  #GET /getuserinfo/:id
  def show
    # ==== research worker id generated ===
    if @user.research_worker_id === nil
      @user.generate_unique_id!
    end
    if @user.image.attached?
      @image_url = url_for(@user.try(:image))
    end
    @message = "user-info"
    @notification = @user.notifications.where(deleted_at: nil).order(id: :desc).limit(30)
    @notification.each do |notification|
      if (notification.status == nil)
        @unread_notification = "yes"
        break
      end
    end
    render json: {Data: {user: @user,notification: @notification, unread_notification: @unread_notification, image_url: @image_url }, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: true}, status: :ok
  end


  #GET /participantinfo/:id
  def participant_info
    render json: {Data: {user: @user, notification: @user.notifications.where(deleted_at: nil).order(id: :desc)},
      CanEdit: false, CanDelete: false, Status: :ok, message: "user-info", Token: nil, Success: false}, status: :ok
  end


  def update
    if @user.update_attributes(user_params)
      @message = "user-profile-updated"
      render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
    else
      render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @user.errors, Token: nil, Success: false}, status: :ok
    end
  end

  def update_image
    if params[:file].present?
      @user.image = params[:file]
      @user.save
      @message = "user-profile-updated"
      render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
    else
      render json: @transaction.errors, status: :unprocessable_entity
    end
  end

  def activate
    @user.status = "active"
    @user.save
    @message = "user-activated"
    render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
  end


  def deactivateuser
    @reason = params[:reason]
    @message = "user-deactivated"
    MailService.deactivate_user(@user.id, @reason)
    render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
  end


  def welcome
    if User.where(confirmation_token: params[:confirmation_token]).present?

      @user = User.find_by(confirmation_token: params[:confirmation_token])
      if @user.present? && @user.email_confirmation_valid?
        if @user.verification_status == "1"
          @message = "already-activated-account"
          render json: {message: @message}, status: :ok
        else
          UserService.verify_user(@user)
          @message = "user-activated"
          render json: {message: @message}, status: :ok
        end
      else
        @message = "Link-expired"
        render json: {message: @message}, status: :ok
      end      
    else
      @message = "Not-a-valid-token"
      render json: {Data: nil, CanEdit: false, CanDelete: false, message: @message, Token: nil, Success: false}, status: :ok
    end
  end


  def share_referral_code
    @receiver = params[:email]
    MailService.share_referral_code(@current_user.id, @receiver)
    @message = "Code-shared"
    render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: true}, status: :ok
  end

  #GET /researcheroverview/:id
  def researcher_overview
    if @user.image.attached?
      @image_url = url_for(@user.try(:image))
    end
    data = UserService.researcher_overview(@user)
    data[:image_url] = @image_url
    render json: {Data: data, CanEdit: false, CanDelete: false, Status: :ok, message: "user-info", Token: nil, Success: false}, status: :ok
  end

  #GET /participantoverview/:id
  def participant_overview
    if @user.image.attached?
      @image_url = url_for(@user.try(:image))
    end
    @message = "user-info"
    @data = UserService.participant_overview(@user)
    @data[:image_url] = @image_url
    render json: {Data: @data, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
  end

  def reports
    @reports = UserService.report
    render json: {Data: @reports, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: true}, status: :ok
  end

  def check_email
    if User.find_by(email: params[:email]).present?
      message = "email-already-exist"
    else
      if params[:email].match?('[a-z0-9]+[_a-z0-9\.-]*[a-z0-9]+@[a-z0-9-]+(\.[a-z0-9-]+)*(\.[a-z]{2,4})')
        message = "valid-email"
      else
        message = "invalid-email"
      end
    end
    render json: {Data: @reports, CanEdit: false, CanDelete: false, Status: :ok, message: message, Token: nil, Success: true}, status: :ok 
  end

  def check_city_pincode
    city = user_params[:city].split.map(&:capitalize).join(' ')
    pincode = user_params[:pincode].split.map(&:capitalize).join(' ')
    if UaePost.where(city: city, po_box_number: pincode).present?
      message = "pincode-matched"
    else
      message = "pincode-miss-matched"
    end
    render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: message, Token: nil, Success: true}, status: :ok 
  end

  private

  def user_params
    params.permit(:email, :password, :first_name, :last_name, :country, :user_type, :university, :university_email, :department,
      :specialisation, :job_type, :referral_code, :address, :contact_number, :nationality, :image_url, :city, :pincode)
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
