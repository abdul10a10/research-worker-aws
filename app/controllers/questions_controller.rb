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
        @response = Response.where(question_id: @question_id, user_id: @user_id, deleted_at: nil)
        @answers = Array.new
          @response.each do |response|
            @answer = Answer.find(response.answer_id)
            @answers.push(@answer.description)
          end
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

  def audience_question
    @study_id = params[:study_id]
    @question_category = params[:question_category]
    @questions = Question.where(question_category: @question_category, deleted_at: nil).order(id: :asc)
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

    # ======================

    @required_users = Array.new
    @user_id = User.select("DISTINCT id").where(deleted_at: nil)
    @user_id.each do |user_id|
      @required_users.push( user_id.id)
    end

    @study = Study.find(@study_id)
    if Audience.where(study_id: @study_id, deleted_at: nil).present?
      @new_array = Array.new
      @question_id = Audience.select("DISTINCT question_id").where(study_id: @study_id, deleted_at: nil)
      
      @question_id.each do |question_id|
        @user_per_question = Array.new
        @audience = Audience.where(question_id: question_id,study_id: @study_id, deleted_at: nil)
        @audience.each do |audience|
          @internal_array = Array.new
          @users = Response.select("DISTINCT user_id").where(question_id: audience.question_id, answer_id: audience.answer_id, deleted_at: nil)
          @users.each do |user|
            @internal_array.push( user.user_id)
          end
          @user_per_question = @user_per_question | @internal_array
        end
        @required_users = @required_users & @user_per_question
      end

      # @audience.each do |audience|
      #   @internal_array = Array.new
      #   @users = Response.select("DISTINCT user_id").where(question_id: audience.question_id, answer_id: audience.answer_id, deleted_at: nil)
      #   @users.each do |user|
      #     @internal_array.push( user.user_id)
      #   end
      #   @new_array = @new_array | @internal_array
      # end
    end
    # @required_users = @required_users & @new_array
    # ======================
    
    @desired_audience_num = @required_users.uniq.count
    @message = "audience-question"
    render json: {Data: {audience_question: @audience_question, desired_audience: @required_users.count}, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
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
