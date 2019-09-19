class TermsAndConditionsController < ApplicationController
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
  end

  # POST /terms_and_conditions
  # POST /terms_and_conditions.json
  def create
    @terms_and_condition = TermsAndCondition.new(terms_and_condition_params)

    if @terms_and_condition.save
      render :show, status: :created, location: @terms_and_condition
    else
      render json: @terms_and_condition.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /terms_and_conditions/1
  # PATCH/PUT /terms_and_conditions/1.json
  def update
    if @terms_and_condition.update(terms_and_condition_params)
      render :show, status: :ok, location: @terms_and_condition
    else
      render json: @terms_and_condition.errors, status: :unprocessable_entity
    end
  end

  # DELETE /terms_and_conditions/1
  # DELETE /terms_and_conditions/1.json
  def destroy
    @terms_and_condition.destroy
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
