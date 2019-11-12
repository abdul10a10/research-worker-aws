class EligibleCandidatesController < ApplicationController
  before_action :authorize_request, only: [:attempt_study, :submit_study, :seen_study]
  before_action :set_eligible_candidate, only: [:show, :update, :destroy]

  # GET /eligible_candidates
  def index
    @eligible_candidates = EligibleCandidate.where(deleted_at: nil)
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
    if EligibleCandidate.where(user_id: @current_user.id, study_id: params[:study_id]).present?
      @eligible_candidate = EligibleCandidate.where(user_id: @current_user.id, study_id: params[:study_id]).first
      @eligible_candidate.start_time!
      # send mail if maximum attempt limit reached
      @study = @eligible_candidate.study
      @eligible_candidates = @study.eligible_candidates.where(is_attempted: '1', deleted_at: nil)
      @attempted_candidate_count = @eligible_candidates.count
      if @attempted_candidate_count >= @study.submission
        UserMailer.with(user: @study.user, study: @study).study_completion_email.deliver_later
        # send notification
        @notification = Notification.new
        @notification.notification_type = "Study Completion"
        @notification.user_id = @user.id
        @study_name = @study.name
        @notification.message = "Maximum attempt has been done for " + @study_name
        @notification.redirect_url = "/candidatesubmissionlist/" + @study_id.to_s
        @notification.save          
      end
      @message = "study-attempted"
      render json: {Data: nil, CanEdit: true, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
    else
      @message = "not-eligible-for-study"
      render json: {Data: nil, CanEdit: true, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
    end
  end

  def seen_study
    if EligibleCandidate.where(user_id: @current_user.id, study_id: params[:study_id]).present?
      @eligible_candidate = EligibleCandidate.where(user_id: @current_user.id, study_id: params[:study_id]).first
      @eligible_candidate.is_seen = 1
      @eligible_candidate.save
      @message = "study-seen"
      render json: {Data: nil, CanEdit: true, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
    else
      @eligible_candidate = EligibleCandidate.new
      @eligible_candidate.user_id = @current_user.id
      @eligible_candidate.study_id = params[:study_id]
      @eligible_candidate.is_seen = 1
      @eligible_candidate.save
      @message = "study-seen"
      render json: {Data: nil, CanEdit: true, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
    end
  end

  def submit_study
    # @user_mail = params[:email]
    # @completioncode = params[:completioncode]
    if Study.find_by(completioncode: params[:completioncode], completionurl: params[:completionurl]).present? && User.find_by(email: params[:email]).present?
      @user = User.find_by(email: params[:email])
      @study = Study.find_by(completioncode: params[:completioncode], completionurl: params[:completionurl])
      @controller_object = EligibleCandidatesController.new
      @study_id = @study.id
      if EligibleCandidate.where(user_id: @user.id, study_id: @study_id, deleted_at: nil).present?
        @eligible_candidate = EligibleCandidate.where(user_id: @user.id, study_id: @study_id).first
        @eligible_candidate.submit_time!
        # auto accept study after 21 days
        @controller_object.delay(run_at: 21.days.from_now).auto_accept_study_submission(@study.user.id, @study.id)
        @message = "study-submitted"
        render json: {Data: @attempted_candidate_count, CanEdit: true, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
      else
        @message = "not-eligible-for-study"
        render json: {Data: @attempted_candidate_count, CanEdit: true, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok 
      end  
    else
      @message = "not-eligible-for-study"
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
    # send reward after 4 days
    @controller_object = EligibleCandidatesController.new
    @controller_object.delay(run_at: 4.days.from_now).send_accept_study_reward(@user.id, @study.id)
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
    # send reward after 25 days
    @controller_object = EligibleCandidatesController.new
    @controller_object.delay(run_at: 25.days.from_now).send_accept_study_reward(@user.id, @study.id)
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

  # method to send money for accepted studies
  def send_accept_study_reward(user_id, study_id)
    @eligible_candidate = EligibleCandidate.where(user_id: user_id, study_id: study_id).first
    @eligible_candidate.is_paid = 1
    @eligible_candidate.save
    @study = Study.find(study_id)
    @user = User.find(user_id)
    @study.study_wallet = @study.study_wallet - @study.reward.to_i
    @user.wallet = @user.wallet + @study.reward.to_i
    @user.save
    @study_name = @study.name
    # track transaction
    @transaction = Transaction.new
    @transaction.transaction_id = SecureRandom.hex(10)
    @transaction.study_id = @study.id
    @transaction.payment_type = "Participant study reward"
    @transaction.sender_id = @study.user_id
    @transaction.receiver_id = @user.id
    @transaction.amount = @study.reward.to_i
    @transaction.description = "Study reward for " + @study_name
    @transaction.save
    # send notification
    @notification = Notification.new
    @notification.notification_type = "Study payment completed"
    @notification.user_id = @user.id
    @notification.message = "Payment for " + @study_name +" study of " + @study.reward + " has been credited in your account"
    @notification.redirect_url = "/"
    @notification.save
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
