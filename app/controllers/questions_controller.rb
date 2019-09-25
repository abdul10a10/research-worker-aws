class QuestionsController < ApplicationController
  before_action :set_question, only: [:show, :update, :destroy]

  # GET /questions
  # GET /questions.json
  def index
    @questions = Question.all.order(id: :asc)
  end

  # GET /questions/1
  # GET /questions/1.json
  def show
  end

  # POST /questions
  # POST /questions.json
  def create
    @question = Question.new(question_params)
    @temp1 = question_params[:question_category]
    @category = QuestionCategory.where(name: @temp1).first
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
      render :show, status: :ok, location: @question
    else
      render json: @question.errors, status: :ok
    end
  end

  # DELETE /questions/1
  # DELETE /questions/1.json
  def destroy
    @question.destroy
  end

  def category_question
    @question_category = params[:question_category]
    @questions = Question.where(question_category: @question_category).order(id: :asc)
    @responce = Array.new
    @questions.each do |question|
      @question_id = question.id
      @answers = Answer.where(question_id: @question_id).order(id: :asc)
      @responce.push({
                         question: question,
                         answer: @answers
                     })


      # @responce = @responce, {question: question, answer: @answers}

    end
    render json: @responce, status: :ok
  end
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_question
      @question = Question.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def question_params
      params.fetch(:question, {}).permit(:question_category, :question_type, :title, :description)
    end
end
