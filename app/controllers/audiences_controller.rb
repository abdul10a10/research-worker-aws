class AudiencesController < ApplicationController
  before_action :set_audience, only: [:show, :update, :destroy]

  # GET /audiences
  def index
    @audiences = Audience.where(deleted_at: nil)
    @message = "All-audience-response"
    render json: {Data: @audiences, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
  end

  # GET /audiences/1
  def show
    @message = "audience-response"
    render json: {Data: @audience, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
  end

  # POST /audiences
  def create
    @audience = Audience.new(audience_params)
    answer_ids = audience_params[:answer_id]
    for answer_id in answer_ids do
      if Answer.where(id: answer_id,question_id: audience_params[:question_id], deleted_at: nil).present?
        @audiencetemp = Audience.new(audience_params)
        @audiencetemp.answer_id = answer_id
        @audiencetemp.save
        @message = "audience-response-saved"
      else
        @message = "please-select-valid-answer"
      end
    end
    render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
  end

  # PATCH/PUT /audiences/1
  def update
    if @audience.update(audience_params)
      @message = "audience-updated"
      render json: {Data: @audience, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
    else
      render json: @audience.errors, status: :unprocessable_entity
    end
  end

  # DELETE /audiences/1
  def destroy
    @audience.destroy
    @message = "audience-deleted"
    render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok

  end

  def delete_audience
    @study_id = params[:study_id]
    @question_id = params[:question_id]
    
    if Audience.where(question_id: @question_id, study_id: @study_id, deleted_at: nil).present?
      @audience = Audience.where(question_id: @question_id, study_id: @study_id, deleted_at: nil)

      @audience.each do |audience|
        audience.deleted_at!
      end
      
      @message = "audience-deleted"
      render json: {message: @message}
    else
      @message = "audience-not-exist"
      render json: {message: @message}, status: :ok
    end
  end

  private
    def set_audience
      if Audience.exists?(params[:id])
        @audience = Audience.find(params[:id])
      else
        @message = "audience-not-found"
        render json: {message: @message}, status: :ok
      end
    end

    def audience_params
      params.fetch(:audience, {}).permit(:study_id, :question_id, :answer_id, :deleted_at, answer_id:[])
    end
end
