class TransactionsController < ApplicationController
  before_action :set_transaction, only: [:show, :update, :destroy]
  before_action :authorize_request, except: [:index]

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

  def researcher_transaction
    studies = @current_user.studies.where(is_paid: "1")
    transactions = Array.new
    studies.each do |study|
      transaction = study.transactions.where(payment_type: "Study Payment")
      if transaction.present?        
        transactions.push(transaction)
      end
    end
    render json: {Data: {transactions: transactions}, CanEdit: false, CanDelete: false, Status: :ok, message: "transaction-of-researcher", Token: nil, Success: false}, status: :ok
  end

  def participant_transaction
    eligible_candidates = EligibleCandidate.where(is_paid: "1")
    transactions = Array.new
    eligible_candidates.each do |eligible_candidate|
      transaction = eligible_candidate.study.transactions
      transactions.push(transaction)
    end
    render json: {Data: {transactions: eligible_candidates}, CanEdit: false, CanDelete: false, Status: :ok, message: "transaction-of-researcher", Token: nil, Success: false}, status: :ok
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
