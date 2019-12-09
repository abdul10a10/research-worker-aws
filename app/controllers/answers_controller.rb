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
    @question = Question.find(@question_id)
    if @question.question_type_id == 4
      if @question.range_answer.present?
        range_answer = @question.range_answer
      else
        range_answer = RangeAnswer.new
        range_answer.question_id = params[:question_id]
      end
      range_answer.min_limit = params[:min_limit]
      range_answer.max_limit = params[:max_limit]
      range_answer.follow_up_question = params[:follow_up_question]
      range_answer.save
      @message = "answer-saved"
    else
      if Answer.where(question_id: @question_id, description: @description, deleted_at: nil).present?
        @message = "answer-already-exist"
      else
        if @answer.save
          @message = "answer-saved"
        else
          @message = "answer-not-saved"
        end
      end        
    end
    render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
  end

  # PATCH/PUT /answers/1
  def update
    if @answer.update(answer_params)
      @message = "answer-updated"
    else
      @message = "answer-not-update"
    end
    render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
  end

  def update_range_answer
    @range_answer = RangeAnswer.find(params[:id])
    @range_answer.min_limit = params[:min_limit]
    @range_answer.max_limit = params[:max_limit]
    @range_answer.save
    @message = "answer-updated"
    render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
  end

  def range_answer_delete
    @range_answer = RangeAnswer.find(params[:id])
    @range_answer.deleted_at!
    @message = "answer-deleted"
    render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
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
    if @question.question_type_id == 4
      @answers = @question.range_answer
    else
      @answers = Answer.where(question_id: @question_id, deleted_at: nil).order(id: :asc)
    end
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
