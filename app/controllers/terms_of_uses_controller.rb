class TermsOfUsesController < ApplicationController
  before_action :set_terms_of_use, only: [:show, :update, :destroy]

  # GET /terms_of_uses
  def index
    @terms_of_uses = TermsOfUse.where(deleted_at: nil)
    @message = "all-terms-of uses"
    render json: {Data: @terms_of_uses, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
  end

  # GET /terms_of_uses/1
  def show
  @message = "terms-of use"
  render json: {Data: @terms_of_use, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
  end

  # POST /terms_of_uses
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
  def update
    if @terms_of_use.update(terms_of_use_params)

      @message = "terms-of-use-updated"
      render json: {Data: @terms_of_use, CanEdit: false, CanDelete: false, Status: :ok, message: @message, Token: nil, Success: false}, status: :ok
    else
      render json: @terms_of_use.errors, status: :unprocessable_entity
    end
  end

  # DELETE /terms_of_uses/1
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
    def set_terms_of_use
      @terms_of_use = TermsOfUse.find(params[:id])
    end

    def terms_of_use_params
      params.fetch(:terms_of_use, {}).permit(:description)
    end
end
