class WhitelistUsersController < ApplicationController
  before_action :set_whitelist_user, only: [:show, :update, :destroy]

  # GET /whitelist_users
  # GET /whitelist_users.json
  def index
    @whitelist_users = WhitelistUser.all
  end

  # GET /whitelist_users/1
  # GET /whitelist_users/1.json
  def show
  end

  # POST /whitelist_users
  # POST /whitelist_users.json
  def create
    @whitelist_user = WhitelistUser.new(whitelist_user_params)
    @research_worker_id = params[:research_worker_id]
    @user = User.find_by(research_worker_id: @research_worker_id )
    
    if WhitelistUser.where(user_id: @user.id, study_id: params[:study_id]).present?
      @message = "user-already-whitelisted"      
    else
      @whitelist_user.user_id = @user.id
      if @whitelist_user.save
        @message = "user-black-listed"
      else
        @message = "error in black-listing"
      end        
    end
    render json: {Data: nil, CanEdit: false, CanDelete: true, Status: :ok, message: @message, Token: nil, Success: true}, status: :ok
  end

  # PATCH/PUT /whitelist_users/1
  # PATCH/PUT /whitelist_users/1.json
  def update
    if @whitelist_user.update(whitelist_user_params)
      render :show, status: :ok, location: @whitelist_user
    else
      render json: @whitelist_user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /whitelist_users/1
  # DELETE /whitelist_users/1.json
  def destroy
    @whitelist_user.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_whitelist_user
      @whitelist_user = WhitelistUser.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def whitelist_user_params
      params.fetch(:whitelist_user, {}).permit(:study_id, :user_id)
    end
end
