class ResponsesController < ApplicationController
  # before_action :authorize_request, except: :create
  before_action :authorize_request, only: :delete_response
  before_action :set_response, only: [:show, :update, :destroy]

  # GET /responses
  def index
    @responses = Response.where(deleted_at: nil)
    render json: @responses
  end

  # GET /responses/1
  def show
    render json: @response, status: :ok
  end

  # POST /responses
  def create
    @response = Response.new(response_params)
    @question = Question.find(@response.question_id)
    if @question.question_type_id == 2
      answer_ids = response_params[:answer_id]
      for answer_id in answer_ids do
        if Answer.where(id: answer_id,question_id: response_params[:question_id], deleted_at: nil).present?
          @responsetemp = Response.new(response_params)
          @responsetemp.answer_id = answer_id
          @responsetemp.save          
          @message = "response-saved"
        else
          @message = "please-select-valid-answer"          
        end
      end
    elsif @question.question_type_id == 4
      if params[:description] == nil
        @message = "please-select-valid-answer"
      else
        @range_response = RangeResponse.new()
        @range_response.user_id = response_params[:user_id]
        @range_response.question_id = response_params[:question_id]
        @range_response.description = params[:description]
        @range_response.save
        @message = "response-saved"
  
      end
    else
      if Answer.where(id: response_params[:answer_id],question_id: response_params[:question_id], deleted_at: nil).present?
        if @response.save
          @message = "response-saved"
        else
          @message = "response-not-saved"
        end
      else
        @message = "please-select-valid-answer"
      end
    end
    render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
  end

  # PATCH/PUT /responses/1
  def update
    if @response.update(response_params)
      render :show, status: :ok, location: @response
    else
      render json: @response.errors, status: :ok
    end
  end

  # DELETE /responses/1
  def destroy
    @response.destroy
    @message = "response-deleted"
    render json: {message: @message}, status: :ok
  end

  #PUT /delete_response
  def delete_response
    @user_id = @current_user.id
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

  def user_response
    @user_id = params[:id]
    @responses = Response.where(user_id: @user_id, deleted_at: nil)
    @message = "user-responses"
    render json: {Data: @responses, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
  end

  def user_response_per_category
    @user_id = params[:id]
    @question_category = params[:question_category_id]
    @responses = Response.where(user_id: @user_id, deleted_at: nil)
    @message = "user-responses-per-category"
    render json: {Data: @responses, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
  end

  private
    def set_response
      @response = Response.find(params[:id])
    end

    def response_params
      params.fetch(:response, {}).permit(:user_id, :question_id, :answer_id, :deleted_at, :text_answer, answer_id:[])
    end
end
