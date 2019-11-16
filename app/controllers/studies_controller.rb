class StudiesController < ApplicationController
  before_action :authorize_request, except: [ :index]
  before_action :is_admin, only: [:activate_study, :reject_study, :admin_new_study_list, :admin_complete_study_list, 
    :admin_active_study_list, :admin_inactive_study_list, :admin_active_study_detail]
  before_action :is_researcher, only: [:show, :create, :update, :add_description, :unpublished_studies, :active_studies,
    :completed_studies, :rejected_studies, :destroy, :pay_for_study, :publish_study, :complete_study, :delete_study, 
    :researcher_active_study_detail, :accepted_candidate_list, :track_active_study_list, :republish]
  before_action :is_participant, only: [:participant_active_study_list, :participant_active_study_detail, :researcher_unique_id]
  before_action :is_admin_or_researcher, only: [:study_detail, :active_candidate_list, :submitted_candidate_list, 
    :paid_candidate_list]
  before_action :set_study, except: [:index, :create, :unpublished_studies, :active_studies, :completed_studies, 
    :rejected_studies, :track_active_study_list, :new_study, :admin_new_study_list, :admin_complete_study_list, 
    :admin_active_study_list, :admin_inactive_study_list, :participant_active_study_list]

  # GET /studies
  def index
    @studies = Study.where(deleted_at: nil).order(id: :desc)
    @message = "all-study"
    render json: {Data: @studies, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
  end

  # ==================================================== Researcher ==========================================================
  # GET /studies/1
  def show
    @message = "study"
    @filtered_candidates = StudyService.filtered_candidate(@study)
    @filtered_candidates_count = @filtered_candidates.count
    render json: {Data: {study: @study, filtered_candidates_count: @filtered_candidates_count}, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
  end

  # POST /studies
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
    if @study.update(study_params)
      @message = "description-added"
      render json: {Data: @study, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok  
    else
      render json: @study.errors, status: :unprocessable_entity
    end
  end

  # GET 'unpublished_studies/:user_id'
  def unpublished_studies
    if Study.where(user_id: params[:user_id], is_active: nil, deleted_at: nil).present?
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
    if Study.where(user_id: params[:user_id], is_active: "1", is_complete: nil, deleted_at: nil).present?
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
    if @study.is_paid == 1
      @message = "payment-already-done"
    else
      StudyService.pay_for_study(@study)
      @message = "payment-done"
    end
    render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok  
  end

  # PUT /publish_study/1
  def publish_study
    if @study.is_published == 1
      @message = "study-already-published"
    else
      StudyService.publish_study(@study)
      @message = "study-published"  
    end
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
    @study.deleted_at!
    @message = "study-deleted"
    render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok        
  end

  def researcher_active_study_detail
    @data = StudyService.researcher_active_study_detail(@study)
    @message = "study"
    render json: {Data: @data, CanEdit: false, CanDelete: true, Status: :ok, message: @message, Token: nil, Success: true}, status: :ok      
  end

  def accepted_candidate_list
    @data = StudyService.accepted_candidate_list(@study)
    render json: {Data: @data, CanEdit: false, CanDelete: true, Status: :ok, message: @message, Token: nil, Success: true}, status: :ok  
  end

  def track_active_study_list
    @data = StudyService.track_active_study_list(@current_user)
    @message = "active-studies"
    render json: {Data: @data, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
  end

  def new_study
    @completioncode = SecureRandom.hex(5)
    @completionurl = "http://winpowerllc.karyonsolutions.com/#/studysubmission/#{SecureRandom.hex(5)}"
    render json: {Data: {completioncode: @completioncode, completionurl: @completionurl}, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false},
    status: :ok
  end

  def republish
    StudyService.republish(@study)
    @message = "study-republished"
    render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false},
    status: :ok
  end

  def select_only_whitelisted
    @study.only_whitelisted = 1
    @study.save
    @message = "only-whitelisted-users-selected"
    render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false},
    status: :ok
  end

  def reject_only_whitelisted
    @study.only_whitelisted = nil
    @study.save
    @message = "only-whitelisted-users-rejected"
    render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false},
    status: :ok
  end
  # ============================================================ Admin =======================================================

  def activate_study
    if @study.is_active == "1"
      @message = "study-already-activated"      
    else
      StudyService.activate_study(@study)
      @message = "study-activated"      
    end
    render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
  end

  def reject_study
    StudyService.reject_study(@study,study_params[:deactivate_reason] )
    @message = "study-rejected"
    render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok    
  end
  
  def admin_new_study_list
    studies = StudyService.admin_new_study_list
    if @studies.present?
      @message = "new-studies"
    else
      @message = "no-study-found"
    end
    render json: {Data: { studies: studies}, CanEdit: false, CanDelete: true, Status: :ok, message: @message, Token: nil, Success: true}, status: :ok      
  end

  def admin_complete_study_list
    @studies = Study.where(is_complete: "1", deleted_at: nil).order(id: :desc)
    render json: {Data: { studies: @studies}, CanEdit: false, CanDelete: true, Status: :ok, message: @message, Token: nil, Success: true}, status: :ok  
  end

  def admin_active_study_list
    if Study.where(is_active: "1", is_complete: nil, deleted_at: nil).present?
      @studies = Study.where(is_active: "1", is_complete: nil,deleted_at: nil).order(id: :desc)
      @message = "active-studies"
    else
      @message = "no-study-found"
    end
    render json: {Data: { studies: @studies}, CanEdit: false, CanDelete: true, Status: :ok, message: @message, Token: nil, Success: true}, status: :ok  
  end

  #  rejected study list
  def admin_inactive_study_list
    studies = StudyService.admin_inactive_study_list
    render json: {Data: { studies: studies}, CanEdit: false, CanDelete: true, Status: :ok, message: @message, Token: nil, Success: true}, status: :ok
  end

  def admin_active_study_detail
    @message = "study"
    @data = StudyService.admin_active_study_detail(@study)
    render json: {Data: @data, CanEdit: false, CanDelete: true, Status: :ok, message: @message, Token: nil, Success: true}, status: :ok      
  end

  # ============================================== Participant ===============================================================

  def participant_active_study_list
    @user = User.find(params[:user_id])
    @data = StudyService.participant_active_study_list(@user)
    render json: {Data: @data, CanEdit: false, CanDelete: true, Status: :ok, message: @message, Token: nil, Success: true}, status: :ok
  end

  def participant_active_study_detail
    @data = StudyService.participant_active_study_detail(@study, @current_user)
    @message = "study"
    render json: {Data: @data, CanEdit: false, CanDelete: true, Status: :ok, message: @message, Token: nil, Success: true}, 
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
    @data = StudyService.active_candidate_list(@study)
    render json: {Data: @data, CanEdit: false, CanDelete: true, Status: :ok, message: @message, Token: nil, Success: true}, status: :ok
  end

  def submitted_candidate_list
    @data = StudyService.submitted_candidate_list(@study)
    @message = "submitted-candidate-list"
    render json: {Data: @data, CanEdit: false, CanDelete: true, Status: :ok, message: @message, Token: nil, Success: true}, status: :ok  
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
