class StudiesController < ApplicationController
  # before_action :authorize_request, except: [:create, :index, :filtered_candidate(id), :find_audience(id)]
  before_action :authorize_request, only: [:active_study_detail, :admin_inactive_study_list, :admin_new_study_list, :admin_complete_study_list, :admin_active_study_list]
  before_action :set_study, only: [:show, :update, :destroy,:paid_candidate_list, :publish_study, :accepted_candidate_list ,:complete_study, :submitted_candidate_list, :activate_study, :reject_study, :study_detail, :active_study_detail, :researcher_active_study_detail, :active_candidate_list, :pay_for_study]

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
    if @current_user.user_type == "Researcher"
      @message = "study"
      @filtered_candidates = filtered_candidate(@study.id)
      @filtered_candidates_count = @filtered_candidates.count
      
      render json: {Data: {study: @study, filtered_candidates:@filtered_candidates, filtered_candidates_count: @filtered_candidates_count}, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
    else
      render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: "unauthorised-user", Token: nil, Success: true}, status: :ok
    end
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
    if @current_user.user_type == "Researcher"
      if @study.update(study_params)
        @message = "study-updated"
        render json: {Data: @study, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok  
      else
        render json: @study.errors, status: :unprocessable_entity
      end
    else
      render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: "unauthorised-user", Token: nil, Success: true}, status: :ok
    end
  end

  # POST /add_description
  def add_description
    if @current_user.user_type == "Researcher"
      @study = Study.find(params[:id])
      if @study.update(study_params)
        @message = "description-added"
        render json: {Data: @study, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok  
      else
        render json: @study.errors, status: :unprocessable_entity
      end
    else
      render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: "unauthorised-user", Token: nil, Success: true}, status: :ok
    end
  end

  # GET 'unpublished_studies/:user_id'
  def unpublished_studies
    if @current_user.user_type == "Researcher"
      if Study.where(user_id: params[:user_id], is_published: nil, deleted_at: nil)
        @studies = Study.where(user_id: params[:user_id], is_published: nil, deleted_at: nil).order(id: :desc)
        @message = "user-studies"
        render json: {Data: @studies, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok 
      else
        @message = "studies-not-found"
        render json: {Data: @studies, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
      end   
    else
      render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: "unauthorised-user", Token: nil, Success: true}, status: :ok
    end
  end

  #GET 'active_studies/:user_id'
  def active_studies
    if @current_user.user_type == "Researcher"
      if Study.where(user_id: params[:user_id], is_active: "1", is_complete: nil, deleted_at: nil)
        @studies = Study.where(user_id: params[:user_id], is_active: "1", is_complete: nil, deleted_at: nil).order(id: :desc)
        @message = "user-studies"
        render json: {Data: @studies, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
      else
        @message = "studies-not-found"
        render json: {Data: @studies, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
      end    
    else
      render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: "unauthorised-user", Token: nil, Success: true}, status: :ok
    end
  end

  #GET 'completed_studies/:user_id'
  def completed_studies
    if @current_user.user_type == "Researcher" || @current_user.user_type == "Admin"
      if Study.where(user_id: params[:user_id], is_complete: "1", deleted_at: nil).present?
        @studies = Study.where(user_id: params[:user_id], is_complete: "1", deleted_at: nil).order(id: :desc)
        @message = "completed-studies"
        render json: {Data: @studies, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok  
      else
        @message = "studies-not-found"
        render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok    
      end  
    else
      render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: "unauthorised-user", Token: nil, Success: true}, status: :ok
    end
  end

  #GET 'rejected_studies/:user_id'
  def rejected_studies
    if @current_user.user_type == "Researcher"
      if Study.where(user_id: params[:user_id], is_active: "0", deleted_at: nil).present?
        @studies = Study.where(user_id: params[:user_id], is_active: "0", deleted_at: nil).order(id: :desc)
        @message = "rejected-studies"
        render json: {Data: @studies, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok  
      else
        @message = "studies-not-found"
        render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok    
      end
  
    else
      render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: "unauthorised-user", Token: nil, Success: true}, status: :ok
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
  def pay_for_study
    if @current_user.user_type == "Researcher"
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
    else
      render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: "unauthorised-user", Token: nil, Success: true}, status: :ok
    end
  end

  # PUT /publish_study/1
  def publish_study
    if @current_user.user_type == "Researcher"
      @controller_object = StudiesController.new
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
      @notification.redirect_url = "/adminnewstudy"
      @notification.save
      # find_audience(@study.id)
      @controller_object.delay(run_at: 1.hours.from_now).auto_activate_study(@study.id)
      @message = "study-published"
      render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok          
    else
      render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: "unauthorised-user", Token: nil, Success: true}, status: :ok
    end
  end

  # Auto activate study after 1 hours of study publish
  def auto_activate_study(id)
    @study = Study.find(id)
    if @study.is_active != "1"
      @study.is_active = 1
      @study.save
      find_audience(@study.id)

      # send mail and notification to researcher
      @user = User.find(@study.user_id)
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

  def activate_study
    if @current_user.user_type == "Admin"
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
      @notification.redirect_url = "/studyactive"
      @notification.save
      render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok    
    else
      render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: "unauthorised-user", Token: nil, Success: true}, status: :ok
    end
  end

  def reject_study
    if @current_user.user_type == "Admin"
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
      @notification.redirect_url = "/studypublished/#{@study.id}"
      @notification.save
      render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok    
    else
      render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: "unauthorised-user", Token: nil, Success: true}, status: :ok
    end
  end
  
  # PUT /complete_study/1
  def complete_study
    if @current_user.user_type == "Researcher"
      @study.is_complete = 1
      @study.save
      @message = "study-completed"
      render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok          
    else
      render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: "unauthorised-user", Token: nil, Success: true}, status: :ok
    end
  end

  def filtered_candidate(id)
    @study_id = id
    @user_ids = Array.new
    @study = Study.find(@study_id)
    # loop to find user_ids
    if Audience.where(study_id: @study_id, deleted_at: nil).present?
      @audience = Audience.where(study_id: @study_id, deleted_at: nil)
      @audience.each do |audience|
        @users = Response.where(question_id: audience.question_id, answer_id: audience.answer_id, deleted_at: nil)
        @users.each do |user|
          @user_ids.push(user.user_id)
        end
      end
    end
    @filtered_candidate_list = Array.new
    @user_ids.uniq.each do|user_id|
      @user = User.find(user_id)
      @filtered_candidate_list.push(@user)
    end
    return @filtered_candidate_list
  end

  # GET /find_audience/:id
  def find_audience(id)
    @study_id = id
    @user_ids = Array.new
    @study = Study.find(@study_id)
    # loop to find user_ids
    # if Audience.where(study_id: @study_id, deleted_at: nil).present?
    #   @audience = Audience.where(study_id: @study_id, deleted_at: nil)
    #   @audience.each do |audience|
    #     @users = Response.where(question_id: audience.question_id, answer_id: audience.answer_id, deleted_at: nil)
    #     @users.each do |user|
    #       @user_ids.push( user.user_id )
    #     end
    #   end
    # else
    #   @message = "audience-not-exist"
    #   render json: {message: @message}, status: :ok
    # end

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
    # @message = "user-ids" 
    # render json: {Data: @user,message: @message}
  end

   
  def delete_study
    if @current_user.user_type == "Researcher"
      @study = Study.find(params[:id])
      @study.deleted_at!
      @message = "study-deleted"
      render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok        
    else
      render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: "unauthorised-user", Token: nil, Success: true}, status: :ok
    end
  end

  def study_detail
    if @current_user.user_type == "Admin" || @current_user.user_type == "Researcher"
      @user = User.find(@study.user_id)
      @message = "study"
      render json: {Data: { study: @study, user: @user}, CanEdit: false, CanDelete: true, Status: :ok, message: @message, Token: nil, Success: true}, status: :ok
    else
      render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: "unauthorised-user", Token: nil, Success: true}, status: :ok
    end
  end

  def admin_new_study_list
    if @current_user.user_type == "Admin"
      @studies = Study.where(is_published: "1", is_active: nil, is_complete: nil,deleted_at: nil).order(id: :desc)
      render json: {Data: { studies: @studies}, CanEdit: false, CanDelete: true, Status: :ok, message: @message, Token: nil, Success: true}, status: :ok   
    else
      render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: "unauthorised-user", Token: nil, Success: true}, status: :ok
    end     
  end

  def admin_complete_study_list
    if @current_user.user_type == "Admin"
      @studies = Study.where(is_complete: "1", deleted_at: nil).order(id: :desc)
      render json: {Data: { studies: @studies}, CanEdit: false, CanDelete: true, Status: :ok, message: @message, Token: nil, Success: true}, status: :ok  
    else
      render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: "unauthorised-user", Token: nil, Success: true}, status: :ok
    end
  end

  def admin_active_study_list
    if @current_user.user_type == "Admin"
      @studies = Study.where(is_active: "1", is_complete: nil,deleted_at: nil).order(id: :desc)
      render json: {Data: { studies: @studies}, CanEdit: false, CanDelete: true, Status: :ok, message: @message, Token: nil, Success: true}, status: :ok
    else
      render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: "unauthorised-user", Token: nil, Success: true}, status: :ok
    end
  end

  def admin_inactive_study_list
    if @current_user.user_type == "Admin"
      @studies = Study.where(is_active: "0", is_complete: nil,deleted_at: nil).order(id: :desc)
      render json: {Data: { studies: @studies}, CanEdit: false, CanDelete: true, Status: :ok, message: @message, Token: nil, Success: true}, status: :ok
    else
      render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: "unauthorised-user", Token: nil, Success: true}, status: :ok
    end
  end


  def participant_active_study_list
    @user = User.find(params[:user_id])
    @eligible_studies = EligibleCandidate.where(user_id: @user.id, deleted_at: nil).order(id: :desc)
    @studies = Array.new
    @eligible_studies.each do |study|
      @eligible_study = Study.find(study.study_id)
      if study.is_attempted == "1"
        @studies.push( eligible_study: @eligible_study, is_attempted: "yes" )
      else
        @studies.push( eligible_study: @eligible_study, is_attempted: "no" )
      end
      
    end
    # @studies = Study.where(is_active: "1", is_complete: nil,deleted_at: nil).order(id: :desc)
    render json: {Data: { studies: @studies}, CanEdit: false, CanDelete: true, Status: :ok, message: @message, Token: nil, Success: true}, status: :ok    
  end


  def active_study_detail
    if @current_user.user_type == "Admin" || @current_user.user_type == "Researcher"
      @message = "study"
      @required_participant = @study.submission
      @active_candidates = EligibleCandidate.where(study_id: @study.id, is_attempted: "1", deleted_at: nil)
      if EligibleCandidate.where(study_id: @study.id, user_id: @current_user.id ,is_attempted: "1", submit_time: nil, deleted_at: nil).present?
        @eligible_candidate = EligibleCandidate.where(study_id: @study.id, user_id: @current_user.id ,is_attempted: "1", submit_time: nil, deleted_at: nil).first
        @estimatetime = @study.estimatetime
        if ((@eligible_candidate.start_time + @estimatetime.to_i.minutes) > Time.now.utc)
          @is_attempted = "yes"
        else
          @is_attempted = "no"
        end
  
      else
        @is_attempted = "no"
      end
      @active_candidate = @active_candidates.count
      render json: {Data: { study: @study, required_participant: @required_participant, active_candidate: @active_candidate, is_attempted: @is_attempted}, CanEdit: false, CanDelete: true, Status: :ok, message: @message, Token: nil, Success: true}, status: :ok  
    else
      render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: "unauthorised-user", Token: nil, Success: true}, status: :ok 
    end
  end


  def researcher_active_study_detail
    if @current_user.user_type == "Researcher"
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
    else
      render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: "unauthorised-user", Token: nil, Success: true}, status: :ok
    end
  end


  def active_candidate_list
    if @current_user.user_type == "Researcher"
      @active_candidates = EligibleCandidate.where(study_id: @study.id, is_attempted: "1", deleted_at: nil)
      @active_candidate = @active_candidates.count
      @active_candidate_list = Array.new
      @active_candidates.each do |candidate|
        @user = User.find(candidate.user_id)
        @active_candidate_list.push(@user)
      end
      render json: {Data: { active_candidate_list: @active_candidate_list}, CanEdit: false, CanDelete: true, Status: :ok, message: @message, Token: nil, Success: true}, status: :ok
    else
      render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: "unauthorised-user", Token: nil, Success: true}, status: :ok
    end
  end


  def submitted_candidate_list
    if @current_user.user_type == "Researcher"
      @submitted_candidates = EligibleCandidate.where(study_id: @study.id, is_completed: "1", is_accepted: nil, deleted_at: nil)
      @submitted_candidate_count = @submitted_candidates.count
      @submitted_candidate_list = Array.new
      @submitted_candidates.each do |candidate|
        @user = User.find(candidate.user_id)
        if (@user.user_type == "Participant")
          @submitted_candidate_list.push(@user)
        end
      end
      render json: {Data: { submitted_candidate_list: @submitted_candidate_list}, CanEdit: false, CanDelete: true, Status: :ok, message: @message, Token: nil, Success: true}, status: :ok  
    else
      render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: "unauthorised-user", Token: nil, Success: true}, status: :ok
    end
  end


  def accepted_candidate_list
    if @current_user.user_type == "Researcher"
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
    else
      render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: "unauthorised-user", Token: nil, Success: true}, status: :ok
    end
  end

  def paid_candidate_list
    if @current_user.user_type == "Researcher"
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
    else
      render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: "unauthorised-user", Token: nil, Success: true}, status: :ok
    end
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
