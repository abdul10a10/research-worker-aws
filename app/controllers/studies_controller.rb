class StudiesController < ApplicationController
  # before_action :authorize_request, except: :create
  before_action :authorize_request, only: [:active_study_detail]
  before_action :set_study, only: [:show, :update, :destroy, :publish_study, :complete_study, :activate_study, :reject_study, :study_detail, :active_study_detail, :researcher_active_study_detail]

  # GET /studies
  # GET /studies.json
  def index
    @studies = Study.where(deleted_at: nil).order(id: :desc)
    @message = "all-study"
    render json: {Data: @studies, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok

  end

  # GET /studies/1
  # GET /studies/1.json
  def show
    @message = "study"
    render json: {Data: @study, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok

  end

  # POST /studies
  # POST /studies.json
  def create
    @study = Study.new(study_params)
    allowedtime = study_params[:allowedtime]
    estimatetime = study_params[:estimatetime]
    if @study.save
      @message = "study-saved"
      render json: {Data: @study, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok  
    else
      render json: @study.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /studies/1
  # PATCH/PUT /studies/1.json
  def update
    if @study.update(study_params)
      @message = "study-updated"
      render json: {Data: @study, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok  
    else
      render json: @study.errors, status: :unprocessable_entity
    end
  end

  # POST /add_description
  def add_description
    @study = Study.find(params[:id])
    if @study.update(study_params)
      @message = "description-added"
      render json: {Data: @study, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok  
    else
      render json: @study.errors, status: :unprocessable_entity
    end
  end

  # GET 'unpublished_studies/:user_id'
  def unpublished_studies

    if Study.where(user_id: params[:user_id], is_published: nil, deleted_at: nil)
      @studies = Study.where(user_id: params[:user_id], is_published: nil, deleted_at: nil).order(id: :desc)
      @message = "user-studies"
      render json: {Data: @studies, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok 
    else
      @message = "studies-not-found"
      render json: {Data: @studies, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
    end 

  end

  #GET 'active_studies/:user_id'
  def active_studies

    if Study.where(user_id: params[:user_id], is_active: "1", is_complete: nil, deleted_at: nil)
      @studies = Study.where(user_id: params[:user_id], is_active: "1", is_complete: nil, deleted_at: nil).order(id: :desc)
      @message = "user-studies"
      render json: {Data: @studies, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
    else
      @message = "studies-not-found"
      render json: {Data: @studies, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
    end  
  end

  #GET 'completed_studies/:user_id'
  def completed_studies
    if Study.where(user_id: params[:user_id], is_complete: "1", deleted_at: nil).present?
      @studies = Study.where(user_id: params[:user_id], is_complete: "1", deleted_at: nil).order(id: :desc)
      @message = "completed-studies"
      render json: {Data: @studies, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok  
    else
      @message = "studies-not-found"
      render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok    
    end
  end

  #GET 'rejected_studies/:user_id'
  def rejected_studies
    if Study.where(user_id: params[:user_id], is_active: "0", deleted_at: nil).present?
      @studies = Study.where(user_id: params[:user_id], is_active: "0", deleted_at: nil).order(id: :desc)
      @message = "rejected-studies"
      render json: {Data: @studies, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok  
    else
      @message = "studies-not-found"
      render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok    
    end
  end

  # DELETE /studies/1
  # DELETE /studies/1.json
  def destroy
    @study.deleted_at!
    @message = "study-deleted"
    render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok  
  end

  # PUT /publish_study/1
  def publish_study
    @study.is_published = 1
    # @study.is_active = 1
    @study.save
    @user = User.where(user_type: "Admin").first
    UserMailer.with(user: @user, study: @study).new_study_creation_email.deliver_later
    @notification = Notification.new
    @notification.notification_type = "Study Created"
    @notification.user_id = @user.id
    @study_name = @study.name
    @notification.message = "New study " + @study_name +" created by "+ @user.first_name
    @notification.redirect_url = "http://winpowerllc.karyonsolutions.com/adminnewstudy"
    @notification.save
    # find_audience(@study.id)
    @message = "study-published"
    render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok  
  end

  def activate_study
    @study.is_active = 1
    # @study.is_active = 1
    @study.save
    find_audience(@study.id)
    @message = "study-activated"
    @user = User.find(@study.user_id)
    UserMailer.with(user: @user, study: @study).study_published_email.deliver_later
    @notification = Notification.new
    @notification.notification_type = "Study Published"
    @notification.user_id = @user.id
    @study_name = @study.name
    @notification.message = "Study " + @study_name +" has been published"
    @notification.redirect_url = "http://winpowerllc.karyonsolutions.com/#/studyactive"
    @notification.save
    render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok  
  end

  def reject_study
    @study.deactivate_reason = study_params[:deactivate_reason]
    @study.is_active = 0
    @study.is_published = 0
    @study.save
    @message = "study-rejected"
    @user = User.find(@study.user_id)
    UserMailer.with(user: @user, study: @study).study_rejection_email.deliver_later
    @notification = Notification.new
    @notification.notification_type = "Study Rejected"
    @notification.user_id = @user.id
    @study_name = @study.name
    @notification.message = "Study " + @study_name +" has been rejected"
    @notification.redirect_url = "http://winpowerllc.karyonsolutions.com/#/studypublished/#{@study.id}"
    @notification.save
    render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok  
  end
  
  # PUT /complete_study/1
  def complete_study
    @study.is_complete = 1
    @study.save
    @message = "study-completed"
    render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok  
  end

  # GET /find_audience/:id
  def find_audience(id)
    @study_id = id
    @user_ids = Array.new
    @study = Study.find(@study_id)
    # loop to find user_ids
    if Audience.where(study_id: @study_id, deleted_at: nil).present?
      @audience = Audience.where(study_id: @study_id, deleted_at: nil)
      @audience.each do |audience|
        @users = Response.where(question_id: audience.question_id, answer_id: audience.answer_id, deleted_at: nil)
        @users.each do |user|
          @user_ids.push( user.user_id )
        end
      end
    else
      @message = "audience-not-exist"
      render json: {message: @message}, status: :ok
    end
    @user_ids.uniq.each do |user_id|
      
      # send mail
      @user = User.find(user_id)
      UserMailer.with(user: @user, study: @study).new_study_invitation_email.deliver_now
      
      # send notification
      @notification = Notification.new
      @notification.notification_type = "Study Invitation"
      @notification.user_id = @user.id
      @study_name = @study.name
      @notification.message = "Invitation to participate in " + @study_name +" study"
      @notification.redirect_url = "http://winpowerllc.karyonsolutions.com/participantstudy"
      @notification.save
      
      #  update eligible candidate list
      @eligible_candidate = EligibleCandidate.new
      @eligible_candidate.user_id = @user.id
      @eligible_candidate.study_id = @study_id
    end
    # @message = "user-ids" 
    # render json: {Data: @user,message: @message}
  end

   
  def delete_study
    @study = Study.find(params[:id])
    @study.deleted_at!
    @message = "study-deleted"
    render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok

  end

  def study_detail
    @user = User.find(@study.user_id)
    @message = "study"
    render json: {Data: { study: @study, user: @user}, CanEdit: false, CanDelete: true, Status: :ok, message: @message, Token: nil, Success: true}, status: :ok    
  end

  def admin_new_study_list
    @studies = Study.where(is_published: "1", is_active: nil, is_complete: nil,deleted_at: nil).order(id: :desc)
    render json: {Data: { studies: @studies}, CanEdit: false, CanDelete: true, Status: :ok, message: @message, Token: nil, Success: true}, status: :ok    
  end

  def admin_complete_study_list
    @studies = Study.where(is_complete: "1", deleted_at: nil).order(id: :desc)
    render json: {Data: { studies: @studies}, CanEdit: false, CanDelete: true, Status: :ok, message: @message, Token: nil, Success: true}, status: :ok    
  end

  def admin_active_study_list
    @studies = Study.where(is_active: "1", is_complete: nil,deleted_at: nil).order(id: :desc)
    render json: {Data: { studies: @studies}, CanEdit: false, CanDelete: true, Status: :ok, message: @message, Token: nil, Success: true}, status: :ok    
  end

  def admin_inactive_study_list
    @studies = Study.where(is_active: "0", is_complete: nil,deleted_at: nil).order(id: :desc)
    render json: {Data: { studies: @studies}, CanEdit: false, CanDelete: true, Status: :ok, message: @message, Token: nil, Success: true}, status: :ok    
  end


  def participant_active_study_list
    @user = User.find(params[:user_id])
    @studies = Study.where(is_active: "1", is_complete: nil,deleted_at: nil).order(id: :desc)
    render json: {Data: { studies: @studies}, CanEdit: false, CanDelete: true, Status: :ok, message: @message, Token: nil, Success: true}, status: :ok    
  end


  def active_study_detail
    @message = "study"
    @required_participant = @study.submission
    @active_candidates = EligibleCandidate.where(study_id: @study.id, is_attempted: "1", deleted_at: nil)
    if EligibleCandidate.where(study_id: @study.id, user_id: @current_user.id ,is_attempted: "1", submit_time: nil, deleted_at: nil).present?
      @is_attempted = "yes"
    else
      @is_attempted = "no"
    end
    @active_candidate = @active_candidates.count
    render json: {Data: { study: @study, required_participant: @required_participant, active_candidate: @active_candidate, is_attempted: @is_attempted}, CanEdit: false, CanDelete: true, Status: :ok, message: @message, Token: nil, Success: true}, status: :ok    
  end


  def researcher_active_study_detail
    @message = "study"
    @required_participant = @study.submission
    @active_candidates = EligibleCandidate.where(study_id: @study.id, is_attempted: "1", deleted_at: nil)
    @active_candidate = @active_candidates.count
    @active_candidate_list = Array.new
    @active_candidates.each do |candidate|
      @user = User.find(candidate.user_id)
      @active_candidate_list.push(@user)
    end
    render json: {Data: { study: @study, required_participant: @required_participant, active_candidate: @active_candidate, active_candidate_list: @active_candidate_list}, CanEdit: false, CanDelete: true, Status: :ok, message: @message, Token: nil, Success: true}, status: :ok    
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_study
      @study = Study.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def study_params
      params.fetch(:study, {}).permit(:user_id, :name, :completionurl, :completioncode, :studyurl, :allowedtime, :estimatetime, :submission, :description, :reward, :deactivate_reason)
    end
end
