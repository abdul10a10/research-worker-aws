class QuestionCategoriesController < ApplicationController
  # before_action :authorize_request, except: :create
  before_action :authorize_request, only: [:about_you, :index]
  before_action :set_question_category, only: [:show, :update, :destroy]

  # GET /question_categories
  # GET /question_categories.json
  def index
    if @current_user.user_type == "Admin" || @current_user.user_type == "Researcher"
      @question_categories = QuestionCategory.where(deleted_at: nil).order(id: :asc)
      render json: {Data: {question_categories: @question_categories}, CanEdit: false, CanDelete: false, Status: :ok, message: "question-categories", Token: nil, Success: true}, status: :ok
    else
      render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: "unauthorised-user", Token: nil, Success: true}, status: :ok
    end
  end

  # GET /question_categories/1
  # GET /question_categories/1.json
  def show
  end


  # POST /question_categories
  # POST /question_categories.json
  def create
    @question_category = QuestionCategory.new(question_category_params)
    @name = QuestionCategory.find_by(name: question_category_params[:name], deleted_at: nil)
    if @name.present?
      @message = "category-already-exist"
      render json: { message: @message}, status: :ok
    else
      if @question_category.save
        @message = "Question-category-added"
        render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
      else
        render json: @question_category.errors, status: :ok
      end
    end
  end


  # PATCH/PUT /question_categories/1
  # PATCH/PUT /question_categories/1.json
  def update
    if @question_category.update(question_category_params)
      @message = "Question-category-updated"
      render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
    else
      @message = "Question-category-not-updated"
      render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
    end
  end


  def delete_question_category
    @question_category = QuestionCategory.find(params[:id])
    @question_category.deleted_at!
    @message = "question-category-deleted"
    render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
  end

  # DELETE /question_categories/1
  # DELETE /question_categories/1.json
  def destroy
    @question_category.destroy
  end


  # GET /about_you/:user_id
  def about_you
    @user_id = @current_user.id
    @question_categories = QuestionCategory.where(deleted_at: nil).order(id: :asc)
    @demographic_category = Array.new
    @total_question = 0
    @total_response = 0
    @question_categories.each do |category|
      @question_category = category.id
      @question = category.questions.where(deleted_at: nil)
      # @question = Question.where(question_category: @question_category, deleted_at: nil)
      @question_count = @question.count
      @total_question = @total_question + @question_count
      @response=0
      @question.each do |question|
        @question_id = question.id
        if Response.where(question_id: @question_id, user_id: @user_id, deleted_at: nil).present?
          @response = @response+1
        end
      end
      @demographic_category.push({
        id: category.id,
        name: category.name,
        image_url: category.image_url,
        question_count: @question_count,
        response: @response
      })
      @total_response = @total_response + @response
    end
    # render json: @demographic_category, status: :ok
    render json: {Data: {demographic_category: @demographic_category, total_question: @total_question, total_response: @total_response}, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_question_category
      @question_category = QuestionCategory.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def question_category_params
      params.fetch(:question_category, {}).permit(:name, :image_url)
    end
end
