class AudiencesController < ApplicationController
  before_action :set_audience, only: [:show, :update, :destroy]

  # GET /audiences
  # GET /audiences.json
  def index
    @audiences = Audience.where(deleted_at: nil)
    @message = "All-audience-response"
    render json: {Data: @audiences, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
  end

  # GET /audiences/1
  # GET /audiences/1.json
  def show
    @message = "audience-response"
    render json: {Data: @audience, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
  end

  # POST /audiences
  # POST /audiences.json
  def create
    @audience = Audience.new(audience_params)
    answer_ids = audience_params[:answer_id]
    for answer_id in answer_ids do
      @audiencetemp = Audience.new(audience_params)
      @audiencetemp.answer_id = answer_id
      @audiencetemp.save
    end
    # if @audience.save
    #   @message = "audience-created"
    #   render json: {Data: @audience, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
    # else
    #   render json: @audience.errors, status: :unprocessable_entity
    # end

    @message = "audience-response-saved"
    render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
  end

  # PATCH/PUT /audiences/1
  # PATCH/PUT /audiences/1.json
  def update
    if @audience.update(audience_params)
      @message = "audience-updated"
      render json: {Data: @audience, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
    else
      render json: @audience.errors, status: :unprocessable_entity
    end
  end

  # DELETE /audiences/1
  # DELETE /audiences/1.json
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
    # Use callbacks to share common setup or constraints between actions.
    def set_audience
      if Audience.exists?(params[:id])
        @audience = Audience.find(params[:id])
      else
        @message = "audience-not-found"
        render json: {message: @message}, status: :ok
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def audience_params
      params.fetch(:audience, {}).permit(:study_id, :question_id, :answer_id, :deleted_at, answer_id:[])
    end
end
