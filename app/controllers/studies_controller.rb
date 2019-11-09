class StudiesController < ApplicationController
  before_action :authorize_request, except: [ :index, :filtered_candidate, :find_audience, :auto_activate_study]
  before_action :is_admin, only: [:activate_study, :reject_study, :admin_new_study_list, :admin_complete_study_list, 
    :admin_active_study_list, :admin_inactive_study_list, :admin_active_study_detail]
  before_action :is_researcher, only: [:show, :create, :update, :add_description, :unpublished_studies, :active_studies,
    :completed_studies, :rejected_studies, :destroy, :pay_for_study, :publish_study, :complete_study, :delete_study, 
    :researcher_active_study_detail, :accepted_candidate_list, :track_active_study_list, :republish]
  before_action :is_participant, only: [:participant_active_study_list, :participant_active_study_detail, :researcher_unique_id]
  before_action :set_study, only: [:show, :researcher_unique_id, :admin_active_study_detail, :update, :destroy,
    :paid_candidate_list, :publish_study, :accepted_candidate_list ,:complete_study, :submitted_candidate_list, 
    :activate_study, :reject_study, :study_detail, :participant_active_study_detail, :researcher_active_study_detail, 
    :active_candidate_list, :pay_for_study, :republish]
  before_action :is_admin_or_researcher, only: [:study_detail, :active_candidate_list, :submitted_candidate_list, 
    :paid_candidate_list]

  # GET /studies
  # GET /studies.json
  def index
    @studies = Study.where(deleted_at: nil).order(id: :desc)
    @message = "all-study"
    render json: {Data: @studies, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok

  end

  # Auto activate study after 1 hours of study publish
  def auto_activate_study(id)
    @study = Study.find(id)
    if @study.is_active != "1"
      @study.is_active = 1
      @study.save
      find_audience(@study.id)

      # send mail and notification to researcher
      @user = @study.user

      # StudyPublish.perform_async(@study.id)
      UserMailer.with(user: @user, study: @study).study_published_email.deliver_later
      @notification = Notification.new
      @notification.notification_type = "Study Published"
      @notification.user_id = @user.id
      @study_name = @study.name
      @notification.message = "Study " + @study_name +" has been published"
      @notification.redirect_url = "/studyactive"
      @notification.save

      # send mail and notification to Admin
      @user = User.where(user_type: "Admin").first
      UserMailer.with(user: @user, study: @study).study_published_email.deliver_later
      @notification = Notification.new
      @notification.notification_type = "Study Published"
      @notification.user_id = @user.id
      @study_name = @study.name
      @notification.message = "Study " + @study_name +" has been published"
      @notification.redirect_url = "/adminactivestudy"
      @notification.save

    end
  end

  def filtered_candidate(id)
    @study_id = id
    # @user_ids = Array.new
    # @study = Study.find(@study_id)
    # # loop to find user_ids
    # if Audience.where(study_id: @study_id, deleted_at: nil).present?
    #   @audience = Audience.where(study_id: @study_id, deleted_at: nil)
    #   @audience.each do |audience|
    #     @users = Response.where(question_id: audience.question_id, answer_id: audience.answer_id, deleted_at: nil)
    #     @users.each do |user|
    #       @user_ids.push(user.user_id)
    #     end
    #   end
    # end
    # @filtered_candidate_list = Array.new
    # @user_ids.uniq.each do|user_id|
    #   @user = User.find(user_id)
    #   @filtered_candidate_list.push(@user)
    # end
    # return @filtered_candidate_list
    @required_audience_list = Array.new
    @required_audience = User.where(user_type: "Participant", verification_status: '1', deleted_at: nil)
    @required_audience.each do |required_audience|
    @required_audience_list.push(required_audience.id)
    end
    @study = Study.find(@study_id)
    if Audience.where(study_id: @study_id, deleted_at: nil).present?
      @study_audience = Audience.select("DISTINCT question_id").where(study_id: @study_id, deleted_at: nil)

      @study_audience.each do |study_audience|
        @audience = Audience.where(question_id: study_audience.question_id, study_id: @study_id, deleted_at: nil)
        @required_users_list = Array.new

        @audience.each do |audience|
          @required_users = Array.new
          @users = Response.where(question_id: audience.question_id, answer_id: audience.answer_id, deleted_at: nil)

          @users.each do |user|
            @required_users.push( user.user_id)
          end

          @required_users_list = @required_users_list + @required_users
        end

        @required_audience_list = @required_users_list & @required_audience_list

      end
    end
    return @required_audience_list
  end

  # GET /find_audience/:id
  def find_audience(id)
    @study_id = id
    # @user_ids = Array.new
    @study = Study.find(@study_id)
    @required_audience_list = Array.new
    @required_audience = User.where(user_type: "Participant", deleted_at: nil)
    @required_audience.each do |required_audience|
    @required_audience_list.push(required_audience.id)
    end
    if Audience.where(study_id: @study_id, deleted_at: nil).present?
      @study_audience = Audience.select("DISTINCT question_id").where(study_id: @study_id, deleted_at: nil)

      @study_audience.each do |study_audience|
        @audience = Audience.where(question_id: study_audience.question_id, study_id: @study_id, deleted_at: nil)
        @required_users_list = Array.new

        @audience.each do |audience|
          @required_users = Array.new
          @users = Response.where(question_id: audience.question_id, answer_id: audience.answer_id, deleted_at: nil)

          @users.each do |user|
            @required_users.push( user.user_id)
          end

          @required_users_list = @required_users_list + @required_users
        end

        @required_audience_list = @required_users_list & @required_audience_list

      end

    end

    @required_audience_list.each do |user_id|
      
      # send mail
      @user = User.find(user_id)
      UserMailer.with(user: @user, study: @study).new_study_invitation_email.deliver_later
      
      # send notification
      @notification = Notification.new
      @notification.notification_type = "Study Invitation"
      @notification.user_id = @user.id
      @study_name = @study.name
      @notification.message = "Invitation to participate in " + @study_name +" study"
      @notification.redirect_url = "/participantstudy"
      @notification.save
      
      #  update eligible candidate list
      @eligible_candidate = EligibleCandidate.new
      @eligible_candidate.user_id = @user.id
      @eligible_candidate.study_id = @study_id
      @eligible_candidate.save
    end
  end

  # ==================================================== Researcher ==========================================================
  # GET /studies/1
  # GET /studies/1.json
  def show
    @message = "study"
    @filtered_candidates = filtered_candidate(@study.id)
    @filtered_candidates_count = @filtered_candidates.count
    render json: {Data: {study: @study, filtered_candidates:@filtered_candidates, filtered_candidates_count: @filtered_candidates_count}, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
  end

  # POST /studies
  # POST /studies.json
  def create
    @study = Study.new(study_params)
    if Study.find_by(completioncode: @study.completioncode).present?
      render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: "completion-code-already-exist", Token: nil, Success: false}, status: :ok
    else
      if @study.save
        @message = "study-saved"
        render json: {Data: @study, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok  
      else
        render json: @study.errors, status: :unprocessable_entity
      end
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
    if Study.where(user_id: params[:user_id], is_active: nil, deleted_at: nil)
      @studies = Study.where(user_id: params[:user_id], is_active: nil, deleted_at: nil).order(id: :desc)
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


  # PUT /pay_for_study/1
  def pay_for_study
    # calculation
    @amount = @study.reward.to_i * @study.submission
    @tax = @amount* 0.20
    @commision = @amount* 0.10
    @total_amount = @amount + @tax + @commision
    @study_wallet = @amount + @tax
    @study.is_paid = 1
    @study.study_wallet = @study_wallet
    @study.save

    @user = User.where(user_type: "Admin").first
    @user.wallet = @user.wallet + @commision
    @user.save

    @study_name = @study.name
    
    # track transaction for study
    @transaction = Transaction.new
    @transaction.transaction_id = SecureRandom.hex(10)
    @transaction.study_id = @study.id
    @transaction.payment_type = "Study Wallet"
    @transaction.sender_id = @study.user_id
    @transaction.amount = @study_wallet
    @transaction.description = "Amount " + @study_wallet.to_s + " has been added to Study wallet"
    @transaction.save
    
    # track transaction for Admin commision
    @transaction = Transaction.new
    @transaction.transaction_id = SecureRandom.hex(10)
    @transaction.study_id = @study.id
    @transaction.payment_type = "Admin commision"
    @transaction.sender_id = @study.user_id
    @transaction.receiver_id = @user.id
    @transaction.amount = @commision
    @transaction.description = "Payment for study " + @study_name + " of " + @commision.to_s + " has been added to your wallet"
    @transaction.save

    #payment notification
    @notification = Notification.new
    @notification.notification_type = "Study Payment commision"
    @notification.user_id = @user.id
    @study_name = @study.name
    @notification.message = "Payment for study " + @study_name + " of " + @commision.to_s + " has been added to your wallet"
    @notification.redirect_url = "/"
    @notification.save
    
    @message = "payment-done"
    render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok  
  end

  # PUT /publish_study/1
  def publish_study
    @controller_object = StudiesController.new
    @study.is_published = 1
    # @study.is_active = 1
    @study.save

    # StudyPublish.perform_async(@study.id)
    @user = User.where(user_type: "Admin").first
    UserMailer.with(user: @user, study: @study).new_study_creation_email.deliver_later
    @notification = Notification.new
    @notification.notification_type = "Study Created"
    @notification.user_id = @user.id
    @study_name = @study.name
    @notification.message = "New study " + @study_name +" created by "+ @user.first_name
    @notification.redirect_url = "/adminnewstudy"
    @notification.save

    @controller_object.delay(run_at: 1.hours.from_now).auto_activate_study(@study.id)
    @message = "study-published"
    render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok          
  end

  # PUT /complete_study/1
  def complete_study
    @study.is_complete = 1
    @study.save
    @message = "study-completed"
    render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok          
  end
   
  def delete_study
    @study = Study.find(params[:id])
    @study.deleted_at!
    @message = "study-deleted"
    render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok        
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
    
    @submitted_candidates = EligibleCandidate.where(study_id: @study.id, is_completed: "1", deleted_at: nil)
    
    @submitted_candidates_list = Array.new
    @submitted_candidates.each do |candidate|
      @user = User.find(candidate.user_id)
      if (@user.user_type == "Participant")
        @submitted_candidates_list.push(@user)
      end
    end
    @submitted_candidate_count = @submitted_candidates_list.count

    @accepted_candidates = EligibleCandidate.where(study_id: @study.id, is_completed: "1", is_accepted: "1", deleted_at: nil)
    @accepted_candidate_count = @accepted_candidates.count
    @accepted_candidate_list = Array.new
    @accepted_candidates.each do |candidate|
      @user = User.find(candidate.user_id)
      if (@user.user_type == "Participant")
        @accepted_candidate_list.push(@user)
      end
    end

    @rejected_candidates = EligibleCandidate.where(study_id: @study.id, is_completed: "1", is_accepted: "0", deleted_at: nil)
    @rejected_candidate_count = @rejected_candidates.count
    @rejected_candidate_list = Array.new
    @rejected_candidates.each do |candidate|
      @user = User.find(candidate.user_id)
      if (@user.user_type == "Participant")
        @rejected_candidate_list.push(@user)
      end
    end

    render json: {Data: { study: @study, 
                          required_participant: @required_participant, 
                          active_candidate: @active_candidate, 
                          active_candidate_list: @active_candidate_list, 
                          submitted_candidate_list: @submitted_candidates_list,
                          accepted_candidate_list: @accepted_candidate_list,
                          rejected_candidate_list: @rejected_candidate_list,
                          rejected_candidate_count: @rejected_candidate_count,
                          accepted_candidate_count: @accepted_candidate_count,
                          submitted_candidate_count: @submitted_candidate_count

                        }, 
                        CanEdit: false, CanDelete: true, Status: :ok, message: @message, Token: nil, Success: true
                  }, status: :ok      
  end

  def accepted_candidate_list
    @accepted_candidates = EligibleCandidate.where(study_id: @study.id, is_completed: "1", is_accepted: "1", deleted_at: nil)
    @accepted_candidate_count = @accepted_candidates.count
    @accepted_candidate_list = Array.new
    @accepted_candidates.each do |candidate|
      @user = User.find(candidate.user_id)
      if (@user.user_type == "Participant")
        @accepted_candidate_list.push(@user)
      end
    end

    @rejected_candidates = EligibleCandidate.where(study_id: @study.id, is_completed: "1", is_accepted: "0", deleted_at: nil)
    @rejected_candidate_count = @rejected_candidates.count
    @rejected_candidate_list = Array.new
    @rejected_candidates.each do |candidate|
      @user = User.find(candidate.user_id)
      if (@user.user_type == "Participant")
        @rejected_candidate_list.push(@user)
      end
    end
    render json: {Data: { accepted_candidate_list: @accepted_candidate_list, rejected_candidate_list: @rejected_candidate_list}, CanEdit: false, CanDelete: true, Status: :ok, message: @message, Token: nil, Success: true}, status: :ok  
  end

  def track_active_study_list
    if Study.where(user_id: @current_user.id, is_active: "1", is_complete: nil, deleted_at: nil)
      @studies = Study.where(user_id: @current_user.id, is_active: "1", is_complete: nil, deleted_at: nil).order(id: :desc)
      @message = "active-studies"
      @study_list = Array.new
      @studies.each do |study|
        @seen_candidates = study.eligible_candidates.where(is_seen: "1", deleted_at: nil)
        @attempted_candidates = study.eligible_candidates.where(is_attempted: "1", deleted_at: nil)
        @submitted_candidates = study.eligible_candidates.where(is_completed: "1", deleted_at: nil)
        @accepted_candidates = study.eligible_candidates.where(is_accepted: "1", deleted_at: nil)
        @rejected_candidates = study.eligible_candidates.where(is_accepted: "0", deleted_at: nil)
        @study_list.push(
          study: study,
          seen_candidates: @seen_candidates.count,
          attempted_candidates: @attempted_candidates.count,
          submitted_candidates: @submitted_candidates.count,
          accepted_candidates: @accepted_candidates.count,
          rejected_candidates: @rejected_candidates.count
        )
      end
      # @active_candidates = EligibleCandidate.where(study_id: @study.id, is_attempted: "1", deleted_at: nil)
      render json: {Data: @study_list, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
    else
      @message = "no-active-found"
      render json: {Data: @studies, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
    end
  end

  def new_study
    @completioncode = SecureRandom.hex
    render json: {Data: @completioncode, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false},
    status: :ok
  end

  def republish
    @study.is_republish = 1
    @study.save

    # StudyRepublish.perform_async(@study.id)
    @eligible_candidates = @study.eligible_candidates.where(is_seen: "1", is_attempted: nil, deleted_at: nil)
    # send notification and mail
    @eligible_candidates.each do |eligible_candidate|
      # send email
      @user = eligible_candidate.user
      StudyMailer.with(user: @user, study: @study).study_reinvitation_email.deliver_later
      # send notification
      @notification = Notification.new
      @notification.notification_type = "Study has been activated again"
      @notification.user_id = eligible_candidate.user.id
      @study_name = @study.name
      @notification.message = "Study " + @study_name +" has been published"
      @notification.redirect_url = "/participantstudy"
      @notification.save
    end

    @message = "study-republished"
    render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false},
    status: :ok
  end
  # ============================================================ Admin =======================================================

  def activate_study
    @study.is_active = 1
    @study.save

    # StudyActivate.perform_async(@study.id)
    find_audience(@study.id)
    @user = User.find(@study.user_id)
    UserMailer.with(user: @user, study: @study).study_published_email.deliver_later
    @notification = Notification.new
    @notification.notification_type = "Study Published"
    @notification.user_id = @user.id
    @study_name = @study.name
    @notification.message = "Study " + @study_name +" has been published"
    @notification.redirect_url = "/studyactive"
    @notification.save

    @message = "study-activated"
    render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
  end

  def reject_study
    @study.deactivate_reason = study_params[:deactivate_reason]
    @study.is_active = 0
    @study.is_published = 0
    @study.save
    @message = "study-rejected"

    # StudyReject.perform_async(@study.id)
    @user = @study.user
    UserMailer.with(user: @user, study: @study).study_rejection_email.deliver_later
    @notification = Notification.new
    @notification.notification_type = "Study Rejected"
    @notification.user_id = @user.id
    @study_name = @study.name
    @notification.message = "Study " + @study_name +" has been rejected"
    @notification.redirect_url = "/studypublished/#{@study.id}"
    @notification.save

    render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok    
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

  #  rejected study list
  def admin_inactive_study_list
    @studies = Study.where(is_active: "0", is_complete: nil,deleted_at: nil).order(id: :desc)
    render json: {Data: { studies: @studies}, CanEdit: false, CanDelete: true, Status: :ok, message: @message, Token: nil, Success: true}, status: :ok
  end

  def admin_active_study_detail
    @message = "study"
    @required_participant = @study.submission
    @active_candidates = EligibleCandidate.where(study_id: @study.id, is_attempted: "1", deleted_at: nil)
    @active_candidate = @active_candidates.count
    @active_candidate_list = Array.new
    @active_candidates.each do |candidate|
      @user = User.find(candidate.user_id)
      @active_candidate_list.push(@user)
    end
    @submitted_candidates = EligibleCandidate.where(study_id: @study.id, is_completed: "1", deleted_at: nil)
    @submitted_candidate_count = @submitted_candidates.count
    @submitted_candidates_list = Array.new
    @submitted_candidates.each do |candidate|
      @user = User.find(candidate.user_id)
      if (@user.user_type == "Participant")
        @submitted_candidates_list.push(@user)
      end
    end

    @accepted_candidates = EligibleCandidate.where(study_id: @study.id, is_completed: "1", is_accepted: "1", deleted_at: nil)
    @accepted_candidate_count = @accepted_candidates.count
    @accepted_candidate_list = Array.new
    @accepted_candidates.each do |candidate|
      @user = User.find(candidate.user_id)
      if (@user.user_type == "Participant")
        @accepted_candidate_list.push(@user)
      end
    end

    @rejected_candidates = EligibleCandidate.where(study_id: @study.id, is_completed: "1", is_accepted: "0", deleted_at: nil)
    @rejected_candidate_count = @rejected_candidates.count
    @rejected_candidate_list = Array.new
    @rejected_candidates.each do |candidate|
      @user = User.find(candidate.user_id)
      if (@user.user_type == "Participant")
        @rejected_candidate_list.push(@user)
      end
    end

    render json: {Data: { study: @study, 
                          required_participant: @required_participant, 
                          active_candidate: @active_candidate, 
                          active_candidate_list: @active_candidate_list, 
                          submitted_candidate_list: @submitted_candidates_list,
                          accepted_candidate_list: @accepted_candidate_list,
                          rejected_candidate_list: @rejected_candidate_list,
                          rejected_candidate_count: @rejected_candidate_count,
                          accepted_candidate_count: @accepted_candidate_count,
                          submitted_candidate_count: @submitted_candidate_count

                        }, 
                        CanEdit: false, CanDelete: true, Status: :ok, message: @message, Token: nil, Success: true
                  }, status: :ok      
  end

  # ============================================== Participant ===============================================================

  def participant_active_study_list
    @user = User.find(params[:user_id])
    @eligible_candidates = EligibleCandidate.where(user_id: @user.id, deleted_at: nil).order(id: :desc)
    @studies = Array.new
    @eligible_candidates.each do |eligible_candidate|
      @eligible_study = eligible_candidate.study
      if @eligible_study.max_participation_date == nil
        if eligible_candidate.is_attempted == "1"
          @studies.push( eligible_study: @eligible_study, is_attempted: "yes" )
        else
          @studies.push( eligible_study: @eligible_study, is_attempted: "no" )
        end          
      else
        if (@eligible_study.max_participation_date + 1.days) >= Time.now.utc
          if eligible_candidate.is_attempted == "1"
            @studies.push( eligible_study: @eligible_study, is_attempted: "yes" )
          else
            @studies.push( eligible_study: @eligible_study, is_attempted: "no" )
          end          
        end  
      end      
    end
    render json: {Data: { studies: @studies.uniq}, CanEdit: false, CanDelete: true, Status: :ok, message: @message, Token: nil, Success: true}, status: :ok
  end

  def participant_active_study_detail
    @message = "study"
    @required_participant = @study.submission
    @active_candidates = EligibleCandidate.where(study_id: @study.id, is_attempted: "1", deleted_at: nil)
    if EligibleCandidate.where(study_id: @study.id, user_id: @current_user.id ,is_attempted: "1", submit_time: nil, deleted_at: nil).present?
      @eligible_candidate = EligibleCandidate.where(study_id: @study.id, user_id: @current_user.id ,is_attempted: "1", submit_time: nil, deleted_at: nil).first
      @estimatetime = @study.estimatetime
      if ((@eligible_candidate.start_time + @estimatetime.to_i.minutes) > Time.now.utc)
        @timer = @eligible_candidate.start_time + @estimatetime.to_i.minutes
        @is_attempted = "yes"
      else
        @is_attempted = "time-out"
      end
    elsif EligibleCandidate.where(study_id: @study.id, user_id: @current_user.id ,is_completed: "1", deleted_at: nil).present?
      @is_attempted = "completed"
    else
      @is_attempted = "no"
    end
    @active_candidate = @active_candidates.count
    if @active_candidate < @required_participant
      @study_status = "active"
    else
      @study_status = "finished"
    end
    render json: {Data: { study: @study, required_participant: @required_participant, active_candidate: @active_candidate, 
      is_attempted: @is_attempted, timer: @timer, study_status: @study_status}, 
      CanEdit: false, CanDelete: true, Status: :ok, message: @message, Token: nil, Success: true}, 
      status: :ok
  end

  def researcher_unique_id
    @user = @study.user
    @message = "user-detail-of-study"
    render json: {Data: { research_worker_id: @user.research_worker_id}, CanEdit: false, CanDelete: true, Status: :ok, message: @message, Token: nil, Success: true}, status: :ok
  end
  
  # ============================================ Admin, Researcher =============================================================

  def study_detail
    @user = @study.user
    @message = "study"
    render json: {Data: { study: @study, user: @user}, CanEdit: false, CanDelete: true, Status: :ok, message: @message, Token: nil, Success: true}, status: :ok
  end

  def active_candidate_list
    @active_candidates = EligibleCandidate.where(study_id: @study.id, is_attempted: "1", deleted_at: nil)
    @active_candidate = @active_candidates.count
    @active_candidate_list = Array.new
    @active_candidates.each do |candidate|
      @user = User.find(candidate.user_id)
      @active_candidate_list.push(@user)
    end
    render json: {Data: { active_candidate_list: @active_candidate_list}, CanEdit: false, CanDelete: true, Status: :ok, message: @message, Token: nil, Success: true}, status: :ok
  end

  def submitted_candidate_list
    @submitted_candidates = EligibleCandidate.where(study_id: @study.id, is_completed: "1", deleted_at: nil)
    @submitted_candidate_count = @submitted_candidates.count
    @submitted_candidate_list = Array.new
    @submitted_candidates.each do |candidate|
      @user = User.find(candidate.user_id)
      if (@user.user_type == "Participant")
        # @completion_time = helpers.distance_of_time_in_words(candidate.submit_time , candidate.start_time)
        time_difference = candidate.submit_time - candidate.start_time
        @completion_time = Time.at(time_difference.to_i.abs).utc.strftime("%H:%M:%S")
        @estimate_min_time = candidate.start_time + @study.allowedtime.to_i.minutes
        @estimate_max_time = candidate.start_time + @study.estimatetime.to_i.minutes
        if candidate.submit_time < @estimate_min_time
          @submission_status = "before-time"
        elsif candidate.submit_time > @estimate_min_time && candidate.submit_time < @estimate_max_time
          @submission_status = "within-time"
        else
          @submission_status = "after-time"
        end
        @submission = candidate.is_completed
        @submitted_candidate_list.push(user: @user, completion_time: @completion_time, start_time: candidate.start_time, submission: @submission, submission_status: @submission_status)
      end
    end
    @message = "submitted-candidate-list"
    render json: {Data: { submitted_candidate_list: @submitted_candidate_list}, CanEdit: false, CanDelete: true, Status: :ok, message: @message, Token: nil, Success: true}, status: :ok  
  end

  def paid_candidate_list
    @paid_candidates = EligibleCandidate.where(study_id: @study.id, is_paid: "1", deleted_at: nil)
    @paid_candidate_count = @paid_candidates.count
    @paid_candidate_list = Array.new
    @paid_candidates.each do |candidate|
      @user = User.find(candidate.user_id)
      if (@user.user_type == "Participant")
        @paid_candidate_list_list.push(@user)
      end
    end
    @message = "paid-candidate-list"
    render json: {Data: { paid_candidate_list: @paid_candidate_list}, CanEdit: false, CanDelete: true, Status: :ok, message: @message, Token: nil, Success: true}, status: :ok  
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_study
      if Study.exists?(params[:id])
        @study = Study.find(params[:id])
      else
        @message = "Study-not-found"
        render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: true}, status: :ok 
      end  
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def study_params
      params.fetch(:study, {}).permit(:user_id, :name, :completionurl, :completioncode, :studyurl, :allowedtime, :estimatetime,
        :submission, :description, :reward, :deactivate_reason, :max_participation_date)
    end
end
