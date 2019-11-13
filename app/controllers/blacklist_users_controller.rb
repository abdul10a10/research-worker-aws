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
    @blacklist_user.user_id = @user.id
    if @blacklist_user.save
      message = "user-black-listed"
      render json: {Data: nil, CanEdit: false, CanDelete: true, Status: :ok, message: @message, Token: nil, Success: true}, status: :ok      
    else
      message = "error in black-listing"
      render json: {Data: nil, CanEdit: false, CanDelete: true, Status: :ok, message: @message, Token: nil, Success: true}, status: :ok      
    end
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
