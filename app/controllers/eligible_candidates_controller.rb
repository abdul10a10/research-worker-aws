class EligibleCandidatesController < ApplicationController
  before_action :authorize_request, only: [:attempt_study, :submit_study, :seen_study]
  before_action :set_eligible_candidate, only: [:show, :update, :destroy]

  # GET /eligible_candidates
  def index
    @eligible_candidates = EligibleCandidate.where(deleted_at: nil).order(id: :desc)
    @message = "Eligible-candidates"
    render json: {Data: @eligible_candidates, CanEdit: true, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
  end

  # GET /eligible_candidates/1
  def show
    @message = "Eligible-candidate"
    render json: {Data: @eligible_candidate, CanEdit: true, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
  end

  # POST /eligible_candidates
  def create
    @eligible_candidate = EligibleCandidate.new(eligible_candidate_params)
    if @eligible_candidate.save
      render :show, status: :created, location: @eligible_candidate
    else
      render json: @eligible_candidate.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /eligible_candidates/1
  def update
    if @eligible_candidate.update(eligible_candidate_params)
      render :show, status: :ok, location: @eligible_candidate
    else
      render json: @eligible_candidate.errors, status: :unprocessable_entity
    end
  end

  # DELETE /eligible_candidates/1
  def destroy
    @eligible_candidate.destroy
  end

  def attempt_study
    study = Study.find(params[:study_id])
    attempted_candidates = study.eligible_candidates.where(is_attempted: "1",deleted_at: nil).count
    rejected_candidates = study.eligible_candidates.where(is_accepted: "0",deleted_at: nil).count
    attempts = attempted_candidates - rejected_candidates
    if attempts < study.submission
      if EligibleCandidate.where(user_id: @current_user.id, study_id: params[:study_id]).present?
        EligibleCandidateService.attempt_study(@current_user.id, params[:study_id])
        @message = "study-attempted"
      else
        @message = "not-eligible-for-study"
      end
    else
      @message = "maximum-attempt-completed"
    end
    render json: {Data: nil, CanEdit: true, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
  end

  def seen_study
    if EligibleCandidate.where(user_id: @current_user.id, study_id: params[:study_id]).present?
      @eligible_candidate = EligibleCandidate.where(user_id: @current_user.id, study_id: params[:study_id]).first
      @eligible_candidate.is_seen = 1
      @eligible_candidate.save
      @message = "study-seen"
      render json: {Data: nil, CanEdit: true, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
    end
  end

  def submit_study
    if Study.find_by(completioncode: params[:completioncode], completionurl: params[:completionurl]).present? && User.find_by(email: params[:email]).present?
      @user = User.find_by(email: params[:email])
      @study = Study.find_by(completioncode: params[:completioncode], completionurl: params[:completionurl])
      @study_id = @study.id
      if EligibleCandidate.where(user_id: @user.id, study_id: @study_id, is_attempted: "1", deleted_at: nil).present?
        if EligibleCandidate.where(user_id: @user.id, study_id: @study_id, deleted_at: nil, is_completed: "1").present?
          @message = "study-already-submitted"
        else
          @eligible_candidate = EligibleCandidate.where(user_id: @user.id, study_id: @study_id).first
          @eligible_candidate.submit_time!
          # auto accept study after 21 days
          EligibleCandidateService.delay(run_at: 21.days.from_now).auto_accept_study_submission(@study.user.id, @study.id)
          # check submission number for referral amount
          if EligibleCandidate.where(user_id: @user.id, is_completed: "1").count == 1
            EligibleCandidateService.referral_program(@user)      
          end
          @message = "study-submitted"
        end
      else
        @message = "study-not-started-yet"
      end  
    else
      @message = "not-eligible-for-study"
    end
    render json: {Data: nil, CanEdit: true, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
  end

  def accept_study_submission
    @eligible_candidate = EligibleCandidate.where(user_id: params[:user_id], study_id: params[:study_id]).first
    @eligible_candidate.is_accepted = 1
    @eligible_candidate.save 
    # send mail
    @study = Study.find(params[:study_id])
    @user = User.find(params[:user_id])
    MailService.study_submission_accept_email(@user.id, @study.id)
    # send notification
    NotificationService.create_notification("Study Submission Accepted", @user.id, 
      "Response of #{@study_name} study has accepted", "/")
    # send reward after 25 days
    EligibleCandidateService.delay(run_at: 25.days.from_now).send_accept_study_reward(@user.id, @study.id)
    @message = "study-accepted"
    render json: {Data: nil, CanEdit: true, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
  end

  def reject_study_submission
    @eligible_candidate = EligibleCandidate.where(user_id: params[:user_id], study_id: params[:study_id]).first
    @eligible_candidate.reject_reason = params[:reject_reason]
    @eligible_candidate.is_accepted = 0
    @eligible_candidate.save
    @study = Study.find(params[:study_id])
    @user = User.find(params[:user_id])
    MailService.study_rejection_accept_email(@user.id, @study.id, @eligible_candidate.id)
    NotificationService.create_notification("Study Submission Rejected", @user.id, 
      "Response of #{@study_name} study has Rejected", "/")
    @message = "study-rejected"
    render json: {Data: nil, CanEdit: true, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok  
  end

  def participant_study_submission
    # @eligible_candidate = EligibleCandidate.where(user_id: user_id, deleted_at: nil)
    user_id = params[:user_id]
    @total_submission = EligibleCandidate.where(user_id: user_id, is_completed: "1", deleted_at: nil)
    @total_attempt = EligibleCandidate.where(user_id: user_id, is_attempted: "1", is_completed: nil, deleted_at: nil)
    @accepted_studies = EligibleCandidate.where(user_id: user_id, is_accepted: "1", deleted_at: nil)
    @rejected_studies = EligibleCandidate.where(user_id: user_id, is_accepted: "0", deleted_at: nil)
    @message = "participant-study-report"
    render json: {Data: {total_submission: @total_submission.count, total_attempt: @total_attempt.count, accepted_studies: @accepted_studies.count, rejected_studies: @rejected_studies.count }, CanEdit: true, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok 
  end

  def total_submission_list
    user_id = params[:user_id]
    @total_submissions = EligibleCandidate.where(user_id: user_id, is_completed: "1", deleted_at: nil)
    @total_submission_count = @total_submissions.count
    @total_submission_list = Array.new
    @total_submissions.each do |study|
      @studies = Study.find(study.study_id)
      @total_submission_list.push(@studies)
    end
    render json: {Data: { total_submission_list: @total_submission_list}, CanEdit: false, CanDelete: true, Status: :ok, message: @message, Token: nil, Success: true}, status: :ok
  end

  def total_attempt_list
    user_id = params[:user_id]
    @total_attempts = EligibleCandidate.where(user_id: user_id, is_attempted: "1", is_completed: nil, deleted_at: nil)
    @total_attempt_count = @total_attempts.count
    @total_attempt_list = Array.new
    @total_attempts.each do |study|
      @studies = Study.find(study.study_id)
      @total_attempt_list.push(@studies)
    end
    render json: {Data: { total_attempt_list: @total_attempt_list}, CanEdit: false, CanDelete: true, Status: :ok, message: @message, Token: nil, Success: true}, status: :ok
  end

  def accepted_study_list
    user_id = params[:user_id]
    @accepted_study = EligibleCandidate.where(user_id: user_id, is_accepted: "1", deleted_at: nil)
    @accepted_study_count = @accepted_study.count
    @accepted_study_list = Array.new
    @accepted_study.each do |study|
      @studies = Study.find(study.study_id)
      @accepted_study_list.push(@studies)
    end
    render json: {Data: { accepted_study_list: @accepted_study_list}, CanEdit: false, CanDelete: true, Status: :ok, message: @message, Token: nil, Success: true}, status: :ok
  end

  def rejected_study_list
    user_id = params[:user_id]
    @rejected_study = EligibleCandidate.where(user_id: user_id, is_accepted: "0", deleted_at: nil)
    @rejected_study_count = @rejected_study.count
    @rejected_study_list = Array.new
    @rejected_study.each do |study|
      @studies = Study.find(study.study_id)
      @rejected_study_list.push(@studies)
    end
    render json: {Data: { rejected_study_list: @rejected_study_list}, CanEdit: false, CanDelete: true, Status: :ok, message: @message, Token: nil, Success: true}, status: :ok
  end

  def participant_ratings
    # participants = EligibleCandidate.group(:user_id).where(is_completed: "1",deleted_at: nil) 
    participants = User.includes(:eligible_candidates).where(eligible_candidates: {is_completed: "1",deleted_at: nil})
    result = Array.new
    participants.each do |user|
      completed_studies = user.eligible_candidates.where(is_completed: "1",deleted_at: nil).count
      accepted_studies = user.eligible_candidates.where(is_accepted: "1",deleted_at: nil).count
      rejected_studies = user.eligible_candidates.where(is_accepted: "0",deleted_at: nil).count
      result.push(user: user, completed_studies: completed_studies, accepted_studies: accepted_studies,
        rejected_studies: rejected_studies)
    end
    render json: {Data: { participants: result}, CanEdit: false, CanDelete: true, Status: :ok, message: @message, Token: nil, Success: true}, status: :ok

  end

  private
    def set_eligible_candidate
      @eligible_candidate = EligibleCandidate.find(params[:id])
    end

    def eligible_candidate_params
      params.fetch(:eligible_candidate, {}).permit(:reject_reason)
    end
end
