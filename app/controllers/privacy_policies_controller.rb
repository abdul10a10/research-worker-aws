class PrivacyPoliciesController < ApplicationController
  before_action :authorize_request, only: :user_policies
  before_action :set_privacy_policy, only: [:show, :update, :destroy]

  # GET /privacy_policies
  def index
    @privacy_policies = PrivacyPolicy.where(deleted_at: nil).order(id: :asc)
    render json: @privacy_policies, status: :ok
  end

  # GET /privacy_policies/1
  def show
    render json: {Data: @privacy_policy, CanEdit: true, CanDelete: false, Status: :ok, message: 'privacy policy', Token: nil, Success: false}, status: :ok
  end

  # POST /privacy_policies
  def create
    @privacy_policy = PrivacyPolicy.new(privacy_policy_params)

    if @privacy_policy.save
      render :show, status: :created, location: @privacy_policy
    else
      render json: @privacy_policy.errors, status: :ok
    end
  end

  # PATCH/PUT /privacy_policies/1
  def update
    if @privacy_policy.update(privacy_policy_params)
      render json: {Data: nil, CanEdit: true, CanDelete: false, Status: :ok, message: 'policy-updated', Token: nil, Success: false}, status: :ok
    else
      render json: {Data: nil, CanEdit: true, CanDelete: false, Status: :ok, message: 'policy-not-updated', Token: nil, Success: false}, status: :ok
    end
  end

  # DELETE /privacy_policies/1
  def destroy
    @privacy_policy.destroy
  end

  def delete_privacy_policy
    @privacy_policy = PrivacyPolicy.find(params[:id])
    @privacy_policy.deleted_at!
    @message = "privacy-policy-deleted"
    render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
  end

  # get /user_terms
  def user_policies
    @privacy_policy = PrivacyPolicy.where(user_type: @current_user.user_type, country: @current_user.country, deleted_at: nil)
    if @privacy_policy.empty?
      @privacy_policy = PrivacyPolicy.where(deleted_at: nil)
    end
    render json: {Data: @privacy_policy, CanEdit: true, CanDelete: false, Status: :ok, message: 'privacy policy', Token: nil, Success: false}, status: :ok
  end

  private
    def set_privacy_policy
      @privacy_policy = PrivacyPolicy.find(params[:id])
    end

    def privacy_policy_params
      params.fetch(:privacy_policy, {}).permit(:country, :user_type, :title, :description)
    end
end
