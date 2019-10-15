class EligibleCandidatesController < ApplicationController
  before_action :authorize_request, only: [:attempt_study, :submit_study]
  before_action :set_eligible_candidate, only: [:show, :update, :destroy]

  # GET /eligible_candidates
  # GET /eligible_candidates.json
  def index
    @eligible_candidates = EligibleCandidate.all
  end

  # GET /eligible_candidates/1
  # GET /eligible_candidates/1.json
  def show
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
    if EligibleCandidate.where(user_id: @current_user.id, study_id: params[:study_id]).present?
      @eligible_candidate = EligibleCandidate.where(user_id: @current_user.id, study_id: params[:study_id]).first
      @eligible_candidate.submit_time!
      @message = "study-submitted"
      render json: {Data: nil, CanEdit: true, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
    else
      @eligible_candidate = EligibleCandidate.new
      @eligible_candidate.user_id = @current_user.id
      @eligible_candidate.study_id = params[:study_id]
      @eligible_candidate.save
      @eligible_candidate.submit_time!
      @message = "study-submitted"
      render json: {Data: nil, CanEdit: true, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_eligible_candidate
      @eligible_candidate = EligibleCandidate.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def eligible_candidate_params
      params.fetch(:eligible_candidate, {})
    end
end
