class QuestionTypesController < ApplicationController
  # before_action :authorize_request, except: :create
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
    @name = QuestionType.find_by(name: params[:name])
    if @name.present?
      @message = "Question-type-already-exist"
      render json: { message: @message}, status:  :ok
    else
      if @question_type.save
        @message = "question-type-saved"
        render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
      else
        render json: @question_type.errors, status: :ok
      end
    end
  end

  # PATCH/PUT /question_types/1
  # PATCH/PUT /question_types/1.json
  def update
    if @question_type.update(question_type_params)
      @message = "question-type-updated"
      render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
    else
      render json: @question_type.errors, status: :ok
    end
  end

  # DELETE /question_types/1
  # DELETE /question_types/1.json
  def destroy
    @question_type.destroy
    @message = "Question-type-deleted"
    render json: { message: @message}, status:  :ok
  end


  def delete_question_type
    @question_type = QuestionType.find(params[:id])
    @question_type.deleted_at!
    @message = "question-type-deleted"
    render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_question_type
      @question_type = QuestionType.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def question_type_params
      params.fetch(:question_type, {}).permit(:name)
    end
end
