class BlacklistUsersController < ApplicationController
  before_action :set_blacklist_user, only: [:show, :update, :destroy]

  # GET /blacklist_users
  # GET /blacklist_users.json
  def index
    @blacklist_users = BlacklistUser.all
  end

  # GET /blacklist_users/1
  # GET /blacklist_users/1.json
  def show
  end

  # POST /blacklist_users
  # POST /blacklist_users.json
  def create
    @blacklist_user = BlacklistUser.new(blacklist_user_params)
    @research_worker_id = params[:research_worker_id]
    @user = User.find_by(research_worker_id: @research_worker_id )
    
    if BlacklistUser.where(user_id: @user.id, study_id: params[:study_id], deleted_at: nil).present?
      @message = "user-already-blacklisted"      
    else
      @blacklist_user.user_id = @user.id
      if @blacklist_user.save
        @message = "user-black-listed"
      else
        @message = "error in black-listing"
      end        
    end
    render json: {Data: nil, CanEdit: false, CanDelete: true, Status: :ok, message: @message, Token: nil, Success: true}, status: :ok
  end

  # PATCH/PUT /blacklist_users/1
  # PATCH/PUT /blacklist_users/1.json
  def update
    if @blacklist_user.update(blacklist_user_params)
      render :show, status: :ok, location: @blacklist_user
    else
      render json: @blacklist_user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /blacklist_users/1
  # DELETE /blacklist_users/1.json
  def destroy
    @blacklist_user.destroy
  end

  def blacklisted_users
    @study = Study.find(params[:study_id])
    @blacklist_users = @study.blacklist_users.where(deleted_at: nil)
    @blacklist_user_list = Array.new
    @blacklist_users.each do |blacklist_user|
      @blacklist_user_list.push(blacklist_user.user)
    end
    render json: {Data: {blacklist_user_list: @blacklist_user_list, study: @study}, CanEdit: false, CanDelete: true, Status: :ok, message: @message, Token: nil, Success: true}, status: :ok 
  end

  def delete_blacklisted_user
    @blacklist_user = BlacklistUser.where(user_id: params[:user_id], study_id: params[:study_id], deleted_at: nil).first
    @blacklist_user.deleted_at!
    @message = "blacklisted-user-deleted"
    render json: {Data: nil, CanEdit: false, CanDelete: true, Status: :ok, message: @message, Token: nil, Success: true}, status: :ok 
  end

  def whitelist_blacklisted_user
    @blacklist_user = BlacklistUser.where(user_id: params[:user_id], study_id: params[:study_id]).first
    @blacklist_user.deleted_at!
    @whitelist_user = WhitelistUser.new(user_id: params[:user_id],study_id: params[:study_id])
    @whitelist_user.save
    @message = "whitelist-blacklisted-user"
    render json: {Data: nil, CanEdit: false, CanDelete: true, Status: :ok, message: @message, Token: nil, Success: true}, status: :ok 
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_blacklist_user
      @blacklist_user = BlacklistUser.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def blacklist_user_params
      params.fetch(:blacklist_user, {}).permit(:study_id, :user_id)
    end
end
