class PrivacyPoliciesController < ApplicationController
  before_action :authorize_request, only: :user_policies
  before_action :set_privacy_policy, only: [:show, :update, :destroy]

  # GET /privacy_policies
  # GET /privacy_policies.json
  def index
    @privacy_policies = PrivacyPolicy.all.order(id: :asc)
    render json: @privacy_policies, status: :ok
  end

  # GET /privacy_policies/1
  # GET /privacy_policies/1.json
  def show
    render json: {Data: @privacy_policy, CanEdit: true, CanDelete: false, Status: :ok, message: 'privacy policy', Token: nil, Success: false}, status: :ok
  end

  # POST /privacy_policies
  # POST /privacy_policies.json
  def create
    @privacy_policy = PrivacyPolicy.new(privacy_policy_params)

    if @privacy_policy.save
      render :show, status: :created, location: @privacy_policy
    else
      render json: @privacy_policy.errors, status: :ok
    end
  end

  # PATCH/PUT /privacy_policies/1
  # PATCH/PUT /privacy_policies/1.json
  def update
    if @privacy_policy.update(privacy_policy_params)
      render json: {Data: nil, CanEdit: true, CanDelete: false, Status: :ok, message: 'policy-updated', Token: nil, Success: false}, status: :ok
    else
      render json: {Data: nil, CanEdit: true, CanDelete: false, Status: :ok, message: 'policy-not-updated', Token: nil, Success: false}, status: :ok
    end
  end

  # DELETE /privacy_policies/1
  # DELETE /privacy_policies/1.json
  def destroy
    @privacy_policy.destroy
  end

  # get /user_terms
  def user_policies
    @privacy_policy = PrivacyPolicy.where(user_type: @current_user.user_type)
    render json: {Data: @privacy_policy, CanEdit: true, CanDelete: false, Status: :ok, message: 'privacy policy', Token: nil, Success: false}, status: :ok
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_privacy_policy
      @privacy_policy = PrivacyPolicy.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def privacy_policy_params
      params.fetch(:privacy_policy, {}).permit(:country, :user_type, :title, :description)
    end
end
