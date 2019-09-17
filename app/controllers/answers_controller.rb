class AnswersController < ApplicationController
  before_action :set_answer, only: [:show, :update, :destroy]

  # GET /answers
  # GET /answers.json
  def index
    @answers = Answer.all
    render json: @answers, status: :ok
  end

  # GET /answers/1
  # GET /answers/1.json
  def show
  end

  # POST /answers
  # POST /answers.json
  def create
    @answer = Answer.new(answer_params)

    if @answer.save
      @message = "answer-saved"
      render json: {answer: @answer, message: @message}, status: :created
    else
      render json: @answer.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /answers/1
  # PATCH/PUT /answers/1.json
  def update
    if @answer.update(answer_params)
      render :show, status: :ok, location: @answer
    else
      render json: @answer.errors, status: :unprocessable_entity
    end
  end

  # DELETE /answers/1
  # DELETE /answers/1.json
  def destroy
    @answer.destroy
  end

  def question_answer
    @question_id = params[:id]
    @question = Question.find(params[:id])
    @answers = Answer.where(question_id: @question_id)
    # render :question_answer, status: :ok
    render json: @answers, status: :ok
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_answer
      @answer = Answer.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def answer_params
      params.fetch(:answer, {}).permit(:question_id, :description, :follow_up_question)
    end
end
