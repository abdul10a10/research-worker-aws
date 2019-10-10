class NotificationsController < ApplicationController
  # before_action :authorize_request, except: :create
  before_action :set_notification, only: [:show, :update, :destroy]

  # GET /notifications
  # GET /notifications.json
  def index
    @notifications = Notification.all
    render json: @notifications, status: :ok
  end

  # GET /notifications/1
  # GET /notifications/1.json
  def show
    render json: @notification, status: :ok
  end

  # POST /notifications
  # POST /notifications.json
  def create
    @notification = Notification.new(notification_params)

    if @notification.save
      render :show, status: :created, location: @notification
    else
      render json: @notification.errors, status: :ok
    end
  end

  # PATCH/PUT /notifications/1
  # PATCH/PUT /notifications/1.json
  def update
    if @notification.update(notification_params)
      render :show, status: :ok, location: @notification
    else
      render json: @notification.errors, status: :ok
    end
  end

  # DELETE /notifications/1
  # DELETE /notifications/1.json
  def destroy
    @notification.destroy
  end

  
  def delete_notifification
    @notification = Notification.find(params[:id])
    @notification.deleted_at!
    @message = "notification-deleted"
    render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok

  end

  #GET /change_seen_status/id
  def change_seen_status
    @notification = Notification.find(params[:id])
    @notification.seen_status = 1
    @notification.seen_time = Time.now.utc
    @notification.save
    @message = "notification-seen"
    render json: {notification: @notification,message: @message}, status: :ok
  end

  #GET /change_status/user_id
  def change_status
    @notification = Notification.where(user_id: params[:user_id], deleted_at: nil)
    @notification.each do |notification|
      notification.status = 1
      notification.save
    end
    @message = "notification-published"
    render json: {message: @message}, status: :ok
  end

  #GET /user_notification/user_id
  def user_notification
    @notification = Notification.where(user_id: params[:user_id], deleted_at: nil).order(id: :desc)
    render json: @notification, status: :ok
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_notification
      @notification = Notification.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def notification_params
      params.fetch(:notification, {}).permit(:notification_type, :user_id, :message, :redirect_url, :seen_status, :status)
    end
end
