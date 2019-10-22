class TransactionsController < ApplicationController
  before_action :set_transaction, only: [:show, :update, :destroy]

  # GET /transactions
  # GET /transactions.json
  def index
    @transactions = Transaction.all.order(id: :desc)
    render json: {Data: @transactions, CanEdit: false, CanDelete: false, Status: :ok, message: "all-transactions", Token: nil, Success: false}, status: :ok
  end

  # GET /transactions/1
  # GET /transactions/1.json
  def show
    render json: {Data: @transaction, CanEdit: false, CanDelete: false, Status: :ok, message: "all-transactions", Token: nil, Success: false}, status: :ok
  end

  # POST /transactions
  # POST /transactions.json
  def create
    @transaction = Transaction.new(transaction_params)

    if @transaction.save
      render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: "transaction-saved", Token: nil, Success: false}, status: :ok
    else
      render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: "transaction-not-saved", Token: nil, Success: false}, status: :ok
    end
  end

  # PATCH/PUT /transactions/1
  # PATCH/PUT /transactions/1.json
  def update
    if @transaction.update(transaction_params)
      render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: "transaction-updated", Token: nil, Success: false}, status: :ok
    else
      render json: @transaction.errors, status: :unprocessable_entity
    end
  end

  # DELETE /transactions/1
  # DELETE /transactions/1.json
  def destroy
    @transaction.destroy
    render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: "transaction-deleted", Token: nil, Success: false}, status: :ok
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_transaction
      @transaction = Transaction.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def transaction_params
      params.fetch(:transaction, {})
    end
end
