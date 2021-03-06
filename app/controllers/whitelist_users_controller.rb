class WhitelistUsersController < ApplicationController
  before_action :set_whitelist_user, only: [:show, :update, :destroy]

  # GET /whitelist_users
  def index
    @whitelist_users = WhitelistUser.all
  end

  # GET /whitelist_users/1
  def show
  end

  # POST /whitelist_users
  def create
    @whitelist_user = WhitelistUser.new(whitelist_user_params)
    @research_worker_id = params[:research_worker_id]
    @user = User.find_by(research_worker_id: @research_worker_id )
    
    if WhitelistUser.where(user_id: @user.id, study_id: params[:study_id], deleted_at: nil).present?
      @message = "user-already-whitelisted"      
    else
      @whitelist_user.user_id = @user.id
      if @whitelist_user.save
        # delete user from blacklist if he is in blacklist
        if BlacklistUser.where(user_id: @user.id, study_id: params[:study_id], deleted_at: nil).present?
          @blacklist_user = BlacklistUser.where(user_id: @user.id, study_id: params[:study_id], deleted_at: nil).first
          @blacklist_user.deleted_at!
        end
        @message = "user-white-listed"
      else
        @message = "error in whitelisting"
      end
    end        
    render json: {Data: nil, CanEdit: false, CanDelete: true, Status: :ok, message: @message, Token: nil, Success: true}, status: :ok
  end

  # PATCH/PUT /whitelist_users/1
  def update
    if @whitelist_user.update(whitelist_user_params)
      render :show, status: :ok, location: @whitelist_user
    else
      render json: @whitelist_user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /whitelist_users/1
  def destroy
    @whitelist_user.destroy
  end

  def whitelisted_users
    @study = Study.find(params[:study_id])
    @whitelist_users = @study.whitelist_users.where(deleted_at: nil)
    @whitelist_user_list = Array.new
    @whitelist_users.each do |whitelist_user|
      @whitelist_user_list.push(whitelist_user.user)
    end
    render json: {Data: {whitelist_user_list: @whitelist_user_list, study: @study}, CanEdit: false, CanDelete: true, Status: :ok, message: @message, Token: nil, Success: true}, status: :ok 
  end

  def delete_whitelisted_user
    @whitelist_user = WhitelistUser.where(user_id: params[:user_id], study_id: params[:study_id], deleted_at: nil).first
    @whitelist_user.deleted_at!
    @message = "whitelisted-user-deleted"
    render json: {Data: nil, CanEdit: false, CanDelete: true, Status: :ok, message: @message, Token: nil, Success: true}, status: :ok 
  end

  def blacklist_whitelisted_user
    @whitelist_user = WhitelistUser.where(user_id: params[:user_id], study_id: params[:study_id], deleted_at: nil).first
    @whitelist_user.deleted_at!
    @blacklist_user = BlacklistUser.new(user_id: params[:user_id],study_id: params[:study_id])
    @blacklist_user.save
    @message = "blacklist-whitelisted-user"
    render json: {Data: nil, CanEdit: false, CanDelete: true, Status: :ok, message: @message, Token: nil, Success: true}, status: :ok 
  end

  private
    def set_whitelist_user
      @whitelist_user = WhitelistUser.find(params[:id])
    end

    def whitelist_user_params
      params.fetch(:whitelist_user, {}).permit(:study_id, :user_id)
    end
end
