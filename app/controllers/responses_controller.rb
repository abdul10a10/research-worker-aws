class ResponsesController < ApplicationController
  before_action :set_response, only: [:show, :update, :destroy]

  # GET /responses
  # GET /responses.json
  def index
    @responses = Response.all
    render json: @responses
  end

  # GET /responses/1
  # GET /responses/1.json
  def show
    render json: @response, status: :ok
  end

  # POST /responses
  # POST /responses.json
  def create
    @response = Response.new(response_params)
    @question = Question.find(@response.question_id)
    if @question.question_type == 2
      answer_ids = response_params[:answer_id]
      for answer_id in answer_ids do
        @responsetemp = Response.new(response_params)
        @responsetemp.answer_id = answer_id
        @responsetemp.save
      end
        @message = "response-saved"
        render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
    else
      if @response.save
        @message = "response-saved"
        render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
      else
        @message = "response-saved"
        render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
      end
    end
    
  end

  # PATCH/PUT /responses/1
  # PATCH/PUT /responses/1.json
  def update
    if @response.update(response_params)
      render :show, status: :ok, location: @response
    else
      render json: @response.errors, status: :ok
    end
  end

  # DELETE /responses/1
  # DELETE /responses/1.json
  def destroy
    @response.destroy
    @message = "response-deleted"
    render json: {message: @message}, status: :ok
  end

  #PUT /delete_response
  def delete_response
    @user_id = params[:user_id]
    @question_id = params[:question_id]
    
    if Response.where(question_id: @question_id, user_id: @user_id, deleted_at: nil).present?
      @response = Response.where(question_id: @question_id, user_id: @user_id, deleted_at: nil)
      @response.each do |response|
        response.deleted_at!
      end
      # @response.deleted_at!
      @message = "response-deleted"
      render json: {message: @message}
    else
      @message = "response-not-exist"
      render json: {message: @message}, status: :ok
    end
    
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_response
      @response = Response.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def response_params
      params.fetch(:response, {}).permit(:user_id, :question_id, :answer_id, :deleted_at, :text_answer, answer_id:[])
    end
end
