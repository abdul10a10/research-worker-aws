class TermsAndConditionsController < ApplicationController
  before_action :authorize_request, only: :user_terms
  before_action :set_terms_and_condition, only: [:show, :update, :destroy]

  # GET /terms_and_conditions
  # GET /terms_and_conditions.json
  def index
    @terms_and_conditions = TermsAndCondition.all.order(id: :asc)
    render json: @terms_and_conditions, status: :ok
  end

  # GET /terms_and_conditions/1
  # GET /terms_and_conditions/1.json
  def show
    render json: {Data: @terms_and_condition, CanEdit: true, CanDelete: false, Status: :ok, message: 'terms and conditions', Token: nil, Success: false}, status: :ok
  end

  # POST /terms_and_conditions
  # POST /terms_and_conditions.json
  def create
    @terms_and_condition = TermsAndCondition.new(terms_and_condition_params)

    if @terms_and_condition.save
      render :show, status: :created, location: @terms_and_condition
    else
      render json: @terms_and_condition.errors, status: :ok
    end
  end

  # PATCH/PUT /terms_and_conditions/1
  # PATCH/PUT /terms_and_conditions/1.json
  def update
    if @terms_and_condition.update(terms_and_condition_params)
      render json: {Data: nil, CanEdit: true, CanDelete: false, Status: :ok, message: 'terms-updated', Token: nil, Success: false}, status: :ok

    else
      render json: {Data: nil, CanEdit: true, CanDelete: false, Status: :ok, message: 'terms-not-updated', Token: nil, Success: false}, status: :ok
    end
  end

  # DELETE /terms_and_conditions/1
  # DELETE /terms_and_conditions/1.json
  def destroy
    @terms_and_condition.destroy
    render json: {Data: nil, CanEdit: true, CanDelete: false, Status: :ok, message: 'terms-deleted', Token: nil, Success: false}, status: :ok
  end

  def delete_terms_and_condition
    @terms_and_condition = TermsAndCondition.find(params[:id])
    @terms_and_condition.deleted_at!
    @message = "terms-and-condition-deleted"
    render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
  end
  
  # get /user_terms
  def user_terms
    @terms_and_condition = TermsAndCondition.where(user_type: @current_user.user_type, country: @current_user.country, deleted_at: nil)
    render json: {Data: @terms_and_condition, CanEdit: false, CanDelete: false, Status: :ok, message: 'terms-and-conditions', Token: nil, Success: false}, status: :ok
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_terms_and_condition
      @terms_and_condition = TermsAndCondition.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def terms_and_condition_params
      params.fetch(:terms_and_condition, {}).permit(:country, :user_type, :title, :description)
    end
end
