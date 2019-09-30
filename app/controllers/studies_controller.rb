class StudiesController < ApplicationController
  before_action :set_study, only: [:show, :update, :destroy]

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

  def add_description
    @study = Study.find(params[:id])
    if @study.update(study_params)
      @message = "description-added"
      render json: {Data: @study, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok  
    else
      render json: @study.errors, status: :unprocessable_entity
    end
  end

  def user_studies
    @studies = Study.find_by(user_id: params[:id])
    @message = "user-studies"
    render json: {Data: @studies, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok  
 
  end
  # DELETE /studies/1
  # DELETE /studies/1.json
  def destroy
    @study.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_study
      @study = Study.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def study_params
      params.fetch(:study, {}).permit(:user_id, :name, :completionurl, :completioncode, :studyurl, :allowedtime, :estimatetime, :submission, :description)
    end
end
