class QuestionTypesController < ApplicationController
  # before_action :authorize_request, except: :create
  before_action :set_question_type, only: [:show, :update, :destroy]

  # GET /question_types
  def index
    @question_types = QuestionType.where(deleted_at: nil)
  end

  # GET /question_types/1
  def show
  end

  # POST /question_types
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
  def update
    if @question_type.update(question_type_params)
      @message = "question-type-updated"
      render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
    else
      render json: @question_type.errors, status: :ok
    end
  end

  # DELETE /question_types/1
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
    def set_question_type
      @question_type = QuestionType.find(params[:id])
    end

    def question_type_params
      params.fetch(:question_type, {}).permit(:name)
    end
end
