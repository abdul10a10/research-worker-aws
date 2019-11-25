class AnswersController < ApplicationController
  # before_action :authorize_request, except: :create
  before_action :authorize_request, only: [:question_answer]
  before_action :is_admin, only:[:question_answer]
  before_action :set_answer, only: [:show, :update, :destroy]

  # GET /answers
  def index
    # @answers = Answer.group(:question_id)
    @answers = Answer.where(deleted_at: nil)
    render json: @answers, status: :ok
  end

  # GET /answers/1
  def show
  end

  # POST /answers
  def create
    @answer = Answer.new(answer_params)
    @question_id = @answer.question_id
    @description = @answer.description

    if Answer.where(question_id: @question_id, description: @description, deleted_at: nil).present?
      @message = "answer-already-exist"
      render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok  
    else
      if @answer.save
        @message = "answer-saved"
        render json: {answer: @answer, message: @message}, status: :created
      else
        render json: @answer.errors, status: :ok
      end
    end
    
  end

  # PATCH/PUT /answers/1
  def update
    if @answer.update(answer_params)
      @message = "answer-updated"
      render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
    else
      @message = "answer-not-update"
      render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
    end
  end

  # DELETE /answers/1
  def destroy
    @answer.deleted_at!
    @message = "answer-deleted"
    render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
  end
  
  def delete_answer
    @answer.destroy
    @message = "answer-deleted"
    render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
  end

  # GET /question_answer/id
  def question_answer
    @question_id = params[:id]
    @question = Question.find(params[:id])
    @follow_up_questions = Question.where(question_category_id: @question.question_category_id, deleted_at: nil)
    @answers = Answer.where(question_id: @question_id, deleted_at: nil).order(id: :asc)
    render json: {Data: {question: @question, answer: @answers, follow_up_questions: @follow_up_questions }, CanEdit: false, CanDelete: false, Status: :ok, message: nil, Token: nil, Success: true}, status: :ok
  end

  private
    def set_answer
      @answer = Answer.find(params[:id])
    end

    def answer_params
      params.fetch(:answer, {}).permit(:question_id, :description, :follow_up_question)
    end
end
