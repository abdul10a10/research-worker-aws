class StudiesController < ApplicationController
  # before_action :authorize_request, except: :create
  before_action :set_study, only: [:show, :update, :destroy, :publish_study, :complete_study]

  # GET /studies
  # GET /studies.json
  def index
    @studies = Study.all
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

    if Study.where(user_id: params[:user_id], is_published: nil)
      @studies = Study.where(user_id: params[:user_id], is_published: nil)
      @message = "user-studies"
      render json: {Data: @studies, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok 
    else
      @message = "studies-not-found"
      render json: {Data: @studies, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
    end 

  end

  #GET 'active_studies/:user_id'
  def active_studies

    if Study.where(user_id: params[:user_id], is_active: "1", is_complete: nil)
      @studies = Study.where(user_id: params[:user_id], is_active: "1", is_complete: nil)
      @message = "user-studies"
      render json: {Data: @studies, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
    else
      @message = "studies-not-found"
      render json: {Data: @studies, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
    end  
  end

  #GET 'completed_studies/:user_id'
  def completed_studies
    if Study.where(user_id: params[:user_id], is_complete: "1").present?
      @studies = Study.where(user_id: params[:user_id], is_complete: "1")
      @message = "completed-studies"
      render json: {Data: @studies, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok  
    else
      @message = "studies-not-found"
      render json: {Data: @studies, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok    
    end
  end

  # DELETE /studies/1
  # DELETE /studies/1.json
  def destroy
    @study.destroy
    @message = "study-deleted"
    render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok  
  end

  # PUT /publish_study/1
  def publish_study
    @study.is_published = 1
    @study.is_active = 1
    @study.save
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

  # GET /find_audience/:id
  def find_audience
    @study_id = params[:id]
    @user_ids = Array.new
    @study = Study.find(@study_id)
    # loop to find user_ids
    if Audience.where(study_id: @study_id, deleted_at: nil).present?
      @audience = Audience.where(study_id: @study_id, deleted_at: nil)
      @audience.each do |audience|
        @users = Response.where(question_id: audience.question_id, answer_id: audience.answer_id)
        @users.each do |user|
          @user_ids.push( user.user_id )
          puts("inside loop")
        end
        puts("outside-loop")
      end
    else
      @message = "audience-not-exist"
      render json: {message: @message}, status: :ok
    end

    i=0
    @user_ids.uniq.each do |user_id|
      @user = User.find(user_id)
      UserMailer.with(user: @user, study: @study).new_study_invitation_email.deliver_later
      i = i+1
      @notification = Notification.new
      @notification.notification_type = "Study Invitation"
      @notification.user_id = @user.id
      @study_name = @study.name
      @notification.message = "Invitation to participate in " + @study_name +" study"

      @notification.redirect_url = "http://winpowerllc.karyonsolutions.com/"

      @notification.save
    end
    #email users
    # UserMailer.with(user: @user).new_study_invitation_mail.deliver_later

    @message = "user-ids"
    render json: {Data: @user,message: @message, i: i}
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_study
      @study = Study.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def study_params
      params.fetch(:study, {}).permit(:user_id, :name, :completionurl, :completioncode, :studyurl, :allowedtime, :estimatetime, :submission, :description, :reward)
    end
end
