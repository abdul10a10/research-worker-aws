class NotificationsController < ApplicationController
  # before_action :authorize_request, except: :create
  before_action :set_notification, only: [:show, :update, :destroy]

  # GET /notifications
  def index
    @notifications = Notification.where(deleted_at: nil)
    render json: @notifications, status: :ok
  end

  # GET /notifications/1
  def show
    render json: @notification, status: :ok
  end

  # POST /notifications
  def create
    @notification = Notification.new(notification_params)

    if @notification.save
      render :show, status: :created, location: @notification
    else
      render json: @notification.errors, status: :ok
    end
  end

  # PATCH/PUT /notifications/1
  def update
    if @notification.update(notification_params)
      render :show, status: :ok, location: @notification
    else
      render json: @notification.errors, status: :ok
    end
  end

  # DELETE /notifications/1
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
    render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
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
    def set_notification
      @notification = Notification.find(params[:id])
    end

    def notification_params
      params.fetch(:notification, {}).permit(:notification_type, :user_id, :message, :redirect_url, :seen_status, :status)
    end
end
