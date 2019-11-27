class QuestionsController < ApplicationController
  # before_action :authorize_request, except: :create
  before_action :authorize_request, only: [:category_question, :question_list]
  before_action :is_admin, only: [:question_list]
  before_action :set_question, only: [:show, :update, :destroy]

  # GET /questions
  def index
    @questions = Question.where(deleted_at: nil).order(id: :asc)
    @message = "questions"
    render json: {Data: @questions, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
  end

  # GET /questions/1
  def show
    @message = "question"
    render json: {Data: @question, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
  end

  # POST /questions
  def create
    @question = Question.new(question_params)
    # @temp1 = question_params[:question_category]
    # @category = QuestionCategory.where(name: @temp1, deleted_at: nil).first
    # @question_category = @category.id
    # @question.question_category = @question_category
    if @question.save
      @message = "question-saved"
      render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
    else
      @message = "question-not-saved"
      render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
     end
  end

  # PATCH/PUT /questions/1
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
  def destroy
    @question.destroy
    @message = "question-deleted"
    render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
  end

  def category_question
    @user_id = @current_user.id
    @question_category = QuestionCategory.find(params[:question_category_id])
    @questions = @question_category.questions.where(deleted_at: nil).order(id: :asc)
    @first_question = @question_category.questions.where(deleted_at: nil).first
    @responce = Array.new
    @follow_up_question = Array.new
    @follow_up_question.push(@first_question.try(:id))
    @questions.each do |question|
      @question_id = question.id
      if Response.where(question_id: @question_id, user_id: @user_id, deleted_at: nil).present?
        @response = Response.where(question_id: @question_id, user_id: @user_id, deleted_at: nil)
        @answers = Array.new
        @response.each do |response|
          @answer = response.answer
          @answers.push(@answer.description)
          @follow_up_question |= [@answer.follow_up_question]
        end
        if @follow_up_question.include? question.id
          @responce.push({
                           question: question,
                           answer_filled: "Yes",
                           answer: @answers
                       })
        end
      else
        @answers = Answer.where(question_id: @question_id, deleted_at: nil).order(id: :asc)
        @answers.each do |answer|
          @follow_up_question |= [answer.follow_up_question]
        end
        if @follow_up_question.include? question.id
          @responce.push({
                            question: question,
                            answer_filled: "No",
                            answer: @answers
                        })
        end
      end
    end
    render json: @responce, status: :ok
  end

  def audience_question
    @study_id = params[:study_id]
    @question_category = QuestionCategory.find(params[:question_category_id])
    @questions = @question_category.questions.where(deleted_at: nil).order(id: :asc)
    # arrray to save all things
    @audience_question = Array.new
    @questions.each do |question|
      @question_id = question.id
      if Audience.where(question_id: @question_id, study_id: @study_id, deleted_at: nil).present?
        @existing_audience = Audience.where(question_id: @question_id, study_id: @study_id, deleted_at: nil)
        @answers = Array.new
          @existing_audience.each do |existing_audience|
            @answer = Answer.find(existing_audience.answer_id)
            @answers.push(@answer.description)
          end
        @audience_question.push({
                           question: question,
                           answer_filled: "Yes",
                           answer: @answers
                       })  
      else
        @answers = Answer.where(question_id: @question_id, deleted_at: nil).order(id: :asc)
        @audience_question.push({
                           question: question,
                           answer_filled: "No",
                           answer: @answers
                       })
      end
    end
    @study = Study.find(@study_id)
    @required_audience_list = StudyService.filtered_candidate(@study)
    @desired_audience_num = @required_audience_list.count

    @message = "audience-question"
    render json: {Data: {audience_question: @audience_question, desired_audience: @desired_audience_num}, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
  end

  def question_list
    @question_category = params[:question_category_id]
    @category = QuestionCategory.find(params[:question_category_id])
    @questions = @category.questions.where(deleted_at: nil).order(id: :asc)
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
    def set_question
      @question = Question.find(params[:id])
    end

    def question_params
      params.fetch(:question, {}).permit(:question_category_id, :question_type_id, :title, :description, :description2)
    end
end
