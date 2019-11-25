class TransactionsController < ApplicationController
  before_action :set_transaction, only: [:show, :update, :destroy]
  before_action :authorize_request, except: [:index]
  before_action :is_admin, only: [:study_transaction]

  # GET /transactions
  def index
    @transactions = Transaction.all.order(id: :desc)
    render json: {Data: @transactions, CanEdit: false, CanDelete: false, Status: :ok, message: "all-transactions", Token: nil, Success: false}, status: :ok
  end

  # GET /transactions/1
  def show
    render json: {Data: @transaction, CanEdit: false, CanDelete: false, Status: :ok, message: "all-transactions", Token: nil, Success: false}, status: :ok
  end

  # POST /transactions
  def create
    @transaction = Transaction.new(transaction_params)

    if @transaction.save
      render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: "transaction-saved", Token: nil, Success: false}, status: :ok
    else
      render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: "transaction-not-saved", Token: nil, Success: false}, status: :ok
    end
  end

  # PATCH/PUT /transactions/1
  def update
    if @transaction.update(transaction_params)
      render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: "transaction-updated", Token: nil, Success: false}, status: :ok
    else
      render json: @transaction.errors, status: :unprocessable_entity
    end
  end

  # DELETE /transactions/1
  def destroy
    @transaction.destroy
    render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: "transaction-deleted", Token: nil, Success: false}, status: :ok
  end

  def researcher_transaction
    studies = @current_user.studies.where(is_paid: "1").order(id: :desc)
    transactions = Array.new
    studies.each do |study|
      transaction = study.transactions.where(payment_type: "Study Payment").first
      if transaction.present?        
        transactions.push(study: study,transaction: transaction)
      end
    end
    render json: {Data: {transactions: transactions}, CanEdit: false, CanDelete: false, Status: :ok, message: "researcher-transactions", Token: nil, Success: false}, status: :ok
  end

  def study_transaction
    studies = Study.where(is_paid: "1").order(id: :desc)
    transactions = Array.new
    studies.each do |study|
      transaction = study.transactions.where(payment_type: "Study Payment").first
      if transaction.present?        
        transactions.push(study: study,transaction: transaction, user: study.user)
      end
    end
    render json: {Data: {transactions: transactions}, CanEdit: false, CanDelete: false, Status: :ok, message: "all-study-transactions", Token: nil, Success: false}, status: :ok
  end

  def participant_transaction
    eligible_candidates = @current_user.eligible_candidates.where(is_paid: "1")
    transactions = Array.new
    eligible_candidates.each do |eligible_candidate|
      study = eligible_candidate.study
      transaction = eligible_candidate.study.where(payment_type: "Participant study reward", receiver_id: @current_user.id).first
      transactions.push(study: study,transaction: transaction)
    end
    render json: {Data: {transactions: transactions}, CanEdit: false, CanDelete: false, Status: :ok, message: "participant-transactions", Token: nil, Success: false}, status: :ok
  end
  private
    def set_transaction
      @transaction = Transaction.find(params[:id])
    end

    def transaction_params
      params.fetch(:transaction, {})
    end
end
