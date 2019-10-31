class MessagesController < ApplicationController
  before_action :set_message, only: [:show, :update, :destroy, :archive_message, :delete_message]

  # GET /messages
  # GET /messages.json
  def index
    @messages = Message.all
    render json: {Data: {messages: @messages}, CanEdit: false, CanDelete: true, Status: :ok, message: @message, Token: nil, Success: true}, status: :ok    
  end

  # GET /messages/1
  # GET /messages/1.json
  def show
    render json: {Data: {message: @message}, CanEdit: false, CanDelete: true, Status: :ok, message: nil, Token: nil, Success: true}, status: :ok    
  end

  # POST /messages
  # POST /messages.json
  def create
    @message = Message.new(message_params)

    if User.where(research_worker_id: params[:research_worker_id] ).present?
      @user = User.where(research_worker_id: params[:research_worker_id] ).first
      if @message.save
        MessageMailer.with(user: @user, message: @message).message_email.deliver_later
        render json: {Data: nil, CanEdit: false, CanDelete: true, Status: :ok, message: "message-sent", Token: nil, Success: true}, status: :ok
      else
        render json: {Data: nil, CanEdit: false, CanDelete: true, Status: :ok, message: "message-not-sent", Token: nil, Success: true}, status: :ok
      end
    else
      render json: {Data: nil, CanEdit: false, CanDelete: true, Status: :ok, message: "user-not-found", Token: nil, Success: true}, status: :ok
    end
    
  end

  # PATCH/PUT /messages/1
  # PATCH/PUT /messages/1.json
  def update
    if @message.update(message_params)
      render :show, status: :ok, location: @message
    else
      render json: @message.errors, status: :unprocessable_entity
    end
  end

  # DELETE /messages/1
  # DELETE /messages/1.json
  def destroy
    @message.destroy
    render json: {Data: nil, CanEdit: false, CanDelete: true, Status: :ok, message: "message-deleted", Token: nil, Success: true}, status: :ok
  end

  def sent_mails
    @sender_id = params[:id]
    if Message.where(sender_id: @sender_id, deleted_at: nil).present?
      @messages = Message.where(sender_id: @sender_id, deleted_at: nil).order(id: :desc)
      render json: {Data: {messages: @messages}, CanEdit: false, CanDelete: true, Status: :ok, message: "sent-mails", Token: nil, Success: true}, status: :ok
    else
      render json: {Data: nil, CanEdit: false, CanDelete: true, Status: :ok, message: "no-mail-found", Token: nil, Success: true}, status: :ok      
    end
  end


  def recieved_mails
    @reciever_id = params[:id]
    if Message.where(reciever_id: @reciever_id, is_archive: nil, deleted_at: nil).present?
      @messages = Message.where(reciever_id: @reciever_id, deleted_at: nil, is_archive: nil).order(id: :desc)
      render json: {Data: {messages: @messages}, CanEdit: false, CanDelete: true, Status: :ok, message: "recieved-mails", Token: nil, Success: true}, status: :ok
    else
      render json: {Data: nil, CanEdit: false, CanDelete: true, Status: :ok, message: "no-mail-found", Token: nil, Success: true}, status: :ok      
    end
  end


  def archive_message
    @message.is_archive = "1"
    @message.save
    render json: {Data: nil, CanEdit: false, CanDelete: true, Status: :ok, message: "no-mail-found", Token: nil, Success: true}, status: :ok
  end


  def delete_message
    @message.deleted_at = Time.now.utc
    @message.save
    render json: {Data: nil, CanEdit: false, CanDelete: true, Status: :ok, message: "message-deleted", Token: nil, Success: true}, status: :ok
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_message
      @message = Message.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def message_params
      # debugger
      params.fetch(:message, {}).permit(:reciever_id,:research_worker_id,:sender_id,:subject, :description)
    end
end