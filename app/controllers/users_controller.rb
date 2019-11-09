class UsersController < ApplicationController 
  # before_action :authorize_request, only: [:dashboard, :reports, :participantoverview]
  before_action :authorize_request, except: [:create, :destroy, :show, :welcome]
  before_action :is_admin, only: [:index, :dashboard, :participant_list, :researcher_list, :deactivate, :activate, 
    :researcheroverview, :participantoverview, :reports]
  # before_action :is_participant, only: [:share_referral_code]
  before_action :set_user, only: [:show, :update, :destroy, :activate, :deactivate, :participant_overview, :researcher_overview, :participant_info]

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
      if @user.save
        @user.generate_email_confirmation_token!
        @user.generate_unique_id!
        # UserConfirmation.perform_async(@user.id)
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
    
    @message = "user-info"
    @notification = @user.notifications.where(deleted_at: nil).order(id: :desc)
    @notification.each do |notification|
      if (notification.status == nil)
        @unread_notification = "yes"
        break
      end
    end
    render json: {Data: {user: @user,notification: @notification, unread_notification: @unread_notification }, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: true}, status: :ok
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

  def activate
    @user.status = "active"
    @user.save
    @message = "user-activated"
    render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
  end


  def deactivate
    @reason = params[:reason]
    @message = "user-deactivated"
    UserService.deactivate_user(@user, @reason)
    # DeactivateUser.perform_async(@user.id, @reason)
    # UserMailer.with(user: @user, reason: @reason).rejection_email.deliver_later
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
      render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :not_found
    end
  end


  def share_referral_code
    @receiver = params[:email]
    # ReferUser.perform_async(@current_user.id, @receiver)
    UserMailer.with(user: @current_user, receiver: @receiver).share_referral_code_email.deliver_later
    @message = "Code-shared"
    render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: true}, status: :ok
  end

  #GET /researcheroverview/:id
  def researcher_overview
    render json: {Data: {user: @user, studies: @user.studies.where(is_published: nil, deleted_at: nil)}, 
      CanEdit: false, CanDelete: false, Status: :ok, message: "user-info", Token: nil, Success: false}, status: :ok
  end

  #GET /participantoverview/:id
  def participant_overview
      @message = "user-info"
      if Response.where(user_id: @user.id, deleted_at: nil).present?
        @demographics = Array.new
        # @response = Response.where(user_id: params[:id]).order(question_id: :asc)
        @question_ids = Response.select("DISTINCT question_id").where(user_id: params[:id], deleted_at: nil).map(&:question_id)
        @question_ids.each do |question_id|
          @response = Response.where(user_id: @user.id, question_id: question_id, deleted_at: nil)
          @question = Question.find(question_id)
          @answers = Array.new
          @response.each do |response|
            @answer = Answer.find(response.answer_id)
            @answers.push(@answer.description)
          end
          @demographics.push({
            question: @question,
            answer: @answers
          })
        end
      end
      render json: {Data: {user: @user, demographics: @demographics}, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
  end

  def reports
    @end_time = Time.now.utc
    @start_time = Time.now.beginning_of_month
    # @users = User.where(created_at: Time.now.beginning_of_year-1.month..@time)
    # @message = "studies-not-found"
    @participant = Array.new
    @researcher = Array.new
    @month = Array.new
    @study = Array.new
    @indian_studies = Array.new
    @uae_studies = Array.new
    i = 0

    loop do
      @participant_user = User.where(created_at: @start_time..@end_time, user_type: "Participant",verification_status: '1', deleted_at: nil)
      @researcher_user = User.where(created_at: @start_time..@end_time, user_type: "Researcher", verification_status: '1', deleted_at: nil)
      @studies = Study.where(created_at: @start_time..@end_time, deleted_at: nil)
      @indian_study = 0
      @uae_study = 0
      @studies.each do |study|
        if study.user.country == "India"
          @indian_study = @indian_study + 1
        elsif study.user.country == "United Arab Emirates" || study.user.country == "UAE"
          @uae_study = @uae_study + 1
        end
      end
      # @indian_studies = @studies.user.where(country: "India", deleted_at: nil)
      # @studies = Study.where(created_at: @start_time..@end_time, deleted_at: nil)
      @participant_count = @participant_user.count
      @researcher_count = @researcher_user.count
      @study_count = @studies.count
      @month_name = @start_time.strftime("%B")
      @participant.push(@participant_count)
      @researcher.push(@researcher_count)
      @study.push(@study_count)
      @month.push(@month_name)
      @indian_studies.push(@indian_study)
      @uae_studies.push(@uae_study) 
      @end_time = @start_time
      @start_time = @start_time-1.month

      i += 1
      if i == 12
        break       
      end
      
    end
    
    render json: {Data: { participant:@participant.reverse, researcher:@researcher.reverse, study: @study.reverse, 
      month: @month.reverse, UAE_studies: @uae_studies.reverse, indian_studies: @indian_studies.reverse },
      CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: true}, status: :ok
  end

  private

  def user_params
    params.permit(:email, :password, :first_name, :last_name, :country, :user_type, :university, :university_email, :department, :specialisation, :job_type, :referral_code, :address, :contact_number, :nationality)
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

# helpers.time_ago_in_words helper to use time time difference 