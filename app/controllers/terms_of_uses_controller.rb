class TermsOfUsesController < ApplicationController
  before_action :set_terms_of_use, only: [:show, :update, :destroy]

  # GET /terms_of_uses
  # GET /terms_of_uses.json
  def index
    @terms_of_uses = TermsOfUse.all
    @message = "all-terms-of uses"
    render json: {Data: @terms_of_uses, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
  end

  # GET /terms_of_uses/1
  # GET /terms_of_uses/1.json
  def show
  @message = "terms-of use"
  render json: {Data: @terms_of_use, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
  end

  # POST /terms_of_uses
  # POST /terms_of_uses.json
  def create
    @terms_of_use = TermsOfUse.new(terms_of_use_params)

    if @terms_of_use.save
      @message = "terms-of-use-saved"
      render json: {Data: @terms_of_use, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
    else
      render json: @terms_of_use.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /terms_of_uses/1
  # PATCH/PUT /terms_of_uses/1.json
  def update
    if @terms_of_use.update(terms_of_use_params)

      @message = "terms-of-use-updated"
      render json: {Data: @terms_of_use, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
    else
      render json: @terms_of_use.errors, status: :unprocessable_entity
    end
  end

  # DELETE /terms_of_uses/1
  # DELETE /terms_of_uses/1.json
  def destroy
    @terms_of_use.destroy
    @message = "terms-of-use-deleted"
    render json: {Data: @terms_of_use, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
  end

  def delete_terms_of_use
    @terms_of_use = TermsOfUse.find(params[:id])
    @terms_of_use.deleted_at!
    @message = "terms-of-use-deleted"
    render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_terms_of_use
      @terms_of_use = TermsOfUse.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def terms_of_use_params
      params.fetch(:terms_of_use, {}).permit(:description)
    end
end
