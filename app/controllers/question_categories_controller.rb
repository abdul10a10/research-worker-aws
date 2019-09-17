class QuestionCategoriesController < ApplicationController
  before_action :set_question_category, only: [:show, :update, :destroy]

  # GET /question_categories
  # GET /question_categories.json
  def index
    @question_categories = QuestionCategory.all
    render :index, status: :ok, location: @question_category
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
        render json: @question_category.errors, status: :unprocessable_entity
      end
    end
  end

  # PATCH/PUT /question_categories/1
  # PATCH/PUT /question_categories/1.json
  def update
    if @question_category.update(question_category_params)
      render :show, status: :ok, location: @question_category
    else
      render json: @question_category.errors, status: :unprocessable_entity
    end
  end

  # DELETE /question_categories/1
  # DELETE /question_categories/1.json
  def destroy
    @question_category.destroy
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
