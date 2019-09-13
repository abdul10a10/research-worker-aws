class QuestionTypesController < ApplicationController
  before_action :set_question_type, only: [:show, :update, :destroy]

  # GET /question_types
  # GET /question_types.json
  def index
    @question_types = QuestionType.all
  end

  # GET /question_types/1
  # GET /question_types/1.json
  def show
  end

  # POST /question_types
  # POST /question_types.json
  def create
    @question_type = QuestionType.new(question_type_params)

    if @question_type.save
      render :show, status: :created, location: @question_type
    else
      render json: @question_type.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /question_types/1
  # PATCH/PUT /question_types/1.json
  def update
    if @question_type.update(question_type_params)
      render :show, status: :ok, location: @question_type
    else
      render json: @question_type.errors, status: :unprocessable_entity
    end
  end

  # DELETE /question_types/1
  # DELETE /question_types/1.json
  def destroy
    @question_type.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_question_type
      @question_type = QuestionType.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def question_type_params
      params.fetch(:question_type, {})
    end
end
