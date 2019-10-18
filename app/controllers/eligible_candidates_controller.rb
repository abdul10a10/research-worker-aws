class EligibleCandidatesController < ApplicationController
  before_action :authorize_request, only: [:attempt_study, :submit_study]
  before_action :set_eligible_candidate, only: [:show, :update, :destroy]

  # GET /eligible_candidates
  # GET /eligible_candidates.json
  def index
    @eligible_candidates = EligibleCandidate.where(deleted_at: nil)
    @message = "Eligible-candidates"
    render json: {Data: @eligible_candidates, CanEdit: true, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok

  end

  # GET /eligible_candidates/1
  # GET /eligible_candidates/1.json
  def show
    @message = "Eligible-candidate"
    render json: {Data: @eligible_candidate, CanEdit: true, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok

  end

  # POST /eligible_candidates
  # POST /eligible_candidates.json
  def create
    @eligible_candidate = EligibleCandidate.new(eligible_candidate_params)

    if @eligible_candidate.save
      render :show, status: :created, location: @eligible_candidate
    else
      render json: @eligible_candidate.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /eligible_candidates/1
  # PATCH/PUT /eligible_candidates/1.json
  def update
    if @eligible_candidate.update(eligible_candidate_params)
      render :show, status: :ok, location: @eligible_candidate
    else
      render json: @eligible_candidate.errors, status: :unprocessable_entity
    end
  end

  # DELETE /eligible_candidates/1
  # DELETE /eligible_candidates/1.json
  def destroy
    @eligible_candidate.destroy
  end

  def attempt_study
    if EligibleCandidate.where(user_id: @current_user.id, study_id: params[:study_id]).present?
      @eligible_candidate = EligibleCandidate.where(user_id: @current_user.id, study_id: params[:study_id]).first
      @eligible_candidate.start_time!
      @message = "study-attempted"
      render json: {Data: nil, CanEdit: true, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
    else
      @eligible_candidate = EligibleCandidate.new
      @eligible_candidate.user_id = @current_user.id
      @eligible_candidate.study_id = params[:study_id]
      @eligible_candidate.save
      @eligible_candidate.start_time!
      @message = "study-attempted"
      render json: {Data: nil, CanEdit: true, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
    end
  end


  def submit_study
    @controller_object = EligibleCandidatesController.new
    if EligibleCandidate.where(user_id: @current_user.id, study_id: params[:study_id], deleted_at: nil).present?
      @eligible_candidate = EligibleCandidate.where(user_id: @current_user.id, study_id: params[:study_id]).first
      @eligible_candidate.submit_time!
      
      # send mail
      @study = Study.find(params[:study_id])
      @user = User.find(@study.user_id)
      UserMailer.with(user: @user, study: @study).study_completion_email.deliver_now
      
      # send notification
      @notification = Notification.new
      @notification.notification_type = "Study Completion"
      @notification.user_id = @user.id
      @study_name = @study.name
      @notification.message = "A participant has completed " + @study_name +" study"
      @notification.redirect_url = "/researcherstudysubmission"
      @notification.save
      
      # auto accept study after 21 days
      @controller_object.delay(run_at: 21.days.from_now).auto_accept_study_submission(@user.id, @study.id)

      @message = "study-submitted"
      render json: {Data: nil, CanEdit: true, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
    else
      @eligible_candidate = EligibleCandidate.new
      @eligible_candidate.user_id = @current_user.id
      @eligible_candidate.study_id = params[:study_id]
      @eligible_candidate.save
      @eligible_candidate.submit_time!

      # auto accept study after 21 days
      @controller_object.delay(run_at: 21.days.from_now).auto_accept_study_submission(@current_user.id, params[:study_id])

      @message = "study-submitted"
      render json: {Data: nil, CanEdit: true, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
    end
  end

  # auto accept study after 21 days
  def auto_accept_study_submission(user_id, study_id)
    @eligible_candidate = EligibleCandidate.where(user_id: user_id, study_id: study_id).first
    @eligible_candidate.is_accepted = 1
    @eligible_candidate.save
     
    # send mail
    @study = Study.find(study_id)
    @user = User.find(user_id)
    UserMailer.with(user: @user, study: @study).study_submission_accept_email.deliver_now
    
    # send notification
    @notification = Notification.new
    @notification.notification_type = "Study Submission Accepted"
    @notification.user_id = @user.id
    @study_name = @study.name
    @notification.message = "Response of " + @study_name +" study has accepted"
    @notification.redirect_url = "/"
    @notification.save
    @message = "study-accepted"

    # send reward after 7 days
    @user.delay(run_at: 7.days.from_now).send_accept_study_reward
  end

  def accept_study_submission
    @eligible_candidate = EligibleCandidate.where(user_id: params[:user_id], study_id: params[:study_id]).first
    @eligible_candidate.is_accepted = 1
    @eligible_candidate.save
     
    # send mail
    @study = Study.find(params[:study_id])
    @user = User.find(params[:user_id])
    UserMailer.with(user: @user, study: @study).study_submission_accept_email.deliver_now
    
    # send notification
    @notification = Notification.new
    @notification.notification_type = "Study Submission Accepted"
    @notification.user_id = @user.id
    @study_name = @study.name
    @notification.message = "Response of " + @study_name +" study has accepted"
    @notification.redirect_url = "/"
    @notification.save
    @message = "study-accepted"

    # send reward after 7 days
    @user.delay(run_at: 7.days.from_now).send_accept_study_reward

    render json: {Data: nil, CanEdit: true, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
  end

  def reject_study_submission
    @eligible_candidate = EligibleCandidate.where(user_id: params[:user_id], study_id: params[:study_id]).first
    @eligible_candidate.reject_reason = params[:reject_reason]
    @eligible_candidate.is_accepted = 0
    @eligible_candidate.save
     
    # send mail
    @study = Study.find(params[:study_id])
    @user = User.find(params[:user_id])
    UserMailer.with(user: @user, study: @study, eligible_candidate: @eligible_candidate).study_rejection_accept_email.deliver_now
    
    # send notification
    @notification = Notification.new
    @notification.notification_type = "Study Submission Rejected"
    @notification.user_id = @user.id
    @study_name = @study.name
    @notification.message = "Response of " + @study_name +" study has been Rejected"
    @notification.redirect_url = "/"
    @notification.save
    @message = "study-rejected"
    render json: {Data: nil, CanEdit: true, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
      
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_eligible_candidate
      @eligible_candidate = EligibleCandidate.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def eligible_candidate_params
      params.fetch(:eligible_candidate, {}).permit(:reject_reason)
    end
end
