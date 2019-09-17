class ResponsesController < ApplicationController
  before_action :set_response, only: [:show, :update, :destroy]

  # GET /responses
  # GET /responses.json
  def index
    @responses = Response.all
  end

  # GET /responses/1
  # GET /responses/1.json
  def show
  end

  # POST /responses
  # POST /responses.json
  def create
    @response = Response.new(response_params)

    if @response.save
      render :show, status: :created, location: @response
    else
      render json: @response.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /responses/1
  # PATCH/PUT /responses/1.json
  def update
    if @response.update(response_params)
      render :show, status: :ok, location: @response
    else
      render json: @response.errors, status: :unprocessable_entity
    end
  end

  # DELETE /responses/1
  # DELETE /responses/1.json
  def destroy
    @response.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_response
      @response = Response.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def response_params
      params.fetch(:response, {}).permit(:user_id, :question_id, :answer_id, :deleted_at)
    end
end
