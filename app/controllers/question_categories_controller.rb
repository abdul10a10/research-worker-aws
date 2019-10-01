class QuestionCategoriesController < ApplicationController
  # before_action :authorize_request, except: :create
  before_action :set_question_category, only: [:show, :update, :destroy]

  # GET /question_categories
  # GET /question_categories.json
  def index
    @question_categories = QuestionCategory.all.order(id: :asc)
    render json: @question_categories, status: :ok
  end

  # GET /question_categories/1
  # GET /question_categories/1.json
  def show
  end


  # POST /question_categories
  # POST /question_categories.json
  def create
    @question_category = QuestionCategory.new(question_category_params)
    @name = QuestionCategory.find_by(name: question_category_params[:name])
    if @name.present?
      @message = "category-already-exist"
      render json: { message: @message}, status: :ok
    else
      if @question_category.save
        render :add, status: :created, location: @question_category
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


  # DELETE /question_categories/1
  # DELETE /question_categories/1.json
  def destroy
    @question_category.destroy
  end


  # GET /about_you/:user_id
  def about_you
    @user_id = params[:user_id]
    @question_categories = QuestionCategory.all.order(id: :asc)
    @demographic_category = Array.new
    @question_categories.each do |category|
      @question_category = category.id
      @question = Question.where(question_category: @question_category)
      @question_count = @question.count
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
        question_count: @question_count,
        response: @response
      })
    end
    render json: @demographic_category, status: :ok
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
