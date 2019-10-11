class QuestionsController < ApplicationController
  # before_action :authorize_request, except: :create
  before_action :authorize_request, only: :category_question
  before_action :set_question, only: [:show, :update, :destroy]

  # GET /questions
  # GET /questions.json
  def index
    @questions = Question.where(deleted_at: nil).order(id: :asc)
    @message = "questions"
    render json: {Data: @questions, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
  end

  # GET /questions/1
  # GET /questions/1.json
  def show
    @message = "question"
    render json: {Data: @question, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
  end

  # POST /questions
  # POST /questions.json
  def create
    @question = Question.new(question_params)
    @temp1 = question_params[:question_category]
    @category = QuestionCategory.where(name: @temp1, deleted_at: nil).first
    @question_category = @category.id
    @question.question_category = @question_category
    if @question.save
      @message = "question-saved"
      render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
    else
      @message = "question-not-saved"
      render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
     end
  end

  # PATCH/PUT /questions/1
  # PATCH/PUT /questions/1.json
  def update
    if @question.update(question_params)
      @message = "question-updated"
      render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
    else
      @message = "question-not-update"
      render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
    end
  end

  # DELETE /questions/1
  # DELETE /questions/1.json
  def destroy
    @question.destroy
    @message = "question-deleted"
    render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
  end

  def category_question
    @user_id = @current_user.id
    @question_category = params[:question_category]
    @questions = Question.where(question_category: @question_category, deleted_at: nil).order(id: :asc)
    @responce = Array.new
    @questions.each do |question|
      @question_id = question.id
      if Response.where(question_id: @question_id, user_id: @user_id, deleted_at: nil).present?

        @answers = Answer.where(question_id: @question_id, deleted_at: nil).order(id: :asc)
        @responce.push({
                           question: question,
                           answer_filled: "Yes",
                           answer: @answers
                       })
  
      else
        @answers = Answer.where(question_id: @question_id, deleted_at: nil).order(id: :asc)
        @responce.push({
                           question: question,
                           answer_filled: "No",
                           answer: @answers
                       })
  
  
        # @responce = @responce, {question: question, answer: @answers}
      end

    end
    render json: @responce, status: :ok
  end

  def question_list
    @question_category = params[:question_category]
    @category = QuestionCategory.find(params[:question_category])
    @questions = Question.where(question_category: @question_category, deleted_at: nil).order(id: :asc)
    @message = 'questions-per-category'
    @data = {
      QuestionCategory: @category,
      Questions: @questions
    }
    render json: {Data: @data, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
  end

  def delete_question
    @question = Question.find(params[:id])
    @question.deleted_at!
    @message = "question-deleted"
    render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok

  end
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_question
      @question = Question.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def question_params
      params.fetch(:question, {}).permit(:question_category, :question_type, :title, :description, :description2)
    end
end
