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
    total_transaction = 0
    total_payment = 0
    transactions = Array.new
    monthly_transaction = Array.new
    monthly_payment = Array.new
    end_time = Time.now.utc
    start_time = Time.now.beginning_of_month
    studies.each do |study|
      transaction = study.transactions.where(payment_type: "Study Payment").first
      if transaction.present?        
        transactions.push(study: study,transaction: transaction)
        total_payment += transaction.amount
      end
    end
    i = 0
    loop do
      paid_studies = @current_user.studies.where(created_at: start_time..end_time, is_paid: "1")
      paid_amount = 0
      transaction_count = 0
      paid_studies.each do |study|
        transaction = study.transactions.where(payment_type: "Study Payment").first
        if transaction.present?
          paid_amount +=  transaction.try(:amount)
          transaction_count +=1
        end
      end
      monthly_payment.push(sprintf('%.2f', paid_amount))
      monthly_transaction.push(transaction_count)
      total_transaction += transaction_count
      
      end_time = start_time
      start_time = start_time-1.month

      i += 1
      if i == 12
        break       
      end
    end
    month = FunctionService.month_array
    render json: {Data: {transactions: transactions, total_payment: sprintf('%.2f', total_payment), total_transaction: total_transaction, monthly_payment: monthly_payment.reverse,
      monthly_transaction: monthly_transaction.reverse, month: month}, CanEdit: false, CanDelete: false, Status: :ok, message: "researcher-transactions", Token: nil, Success: false}, status: :ok
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
    month = FunctionService.month_array
    transactions_data = TransactionService.total_monthly_transaction
    render json: {Data: {transactions: transactions, 
      total_transaction: transactions_data[:total_transaction],
      indian_transactions: transactions_data[:indian_transactions],
      uae_transactions: transactions_data[:uae_transactions],
      other_country_transactions: transactions_data[:other_country_transactions],
      total_payment: transactions_data[:total_payment],
      total_indian_payment: transactions_data[:total_indian_payment],
      total_uae_payment: transactions_data[:total_uae_payment],
      total_other_country_payment: transactions_data[:total_other_country_payment],
      monthly_uae_payment: transactions_data[:monthly_uae_payment],
      monthly_other_country_payment: transactions_data[:monthly_other_country_payment],
      monthly_indian_payment: transactions_data[:monthly_indian_payment],
      payment_array: transactions_data[:payment_array],
      month: month, 
      monthly_transaction: transactions_data[:monthly_transaction],
      monthly_payment: transactions_data[:monthly_payment]
      }, CanEdit: false, CanDelete: false, Status: :ok, message: "all-study-transactions", Token: nil, Success: false}, status: :ok
  end

  def participant_transaction
    eligible_candidates = @current_user.eligible_candidates.where(is_paid: "1")
    transactions = Array.new


    total_transaction = 0
    total_payment = 0
    transactions = Array.new
    monthly_transaction = Array.new
    monthly_payment = Array.new
    end_time = Time.now.utc
    start_time = Time.now.beginning_of_month
    i = 0
    loop do
      eligible_candidates = @current_user.eligible_candidates.where(created_at: start_time..end_time, is_paid: "1")
      paid_amount = 0
      transaction_count = 0
      eligible_candidates.each do |eligible_candidate|
        study = eligible_candidate.study
        transaction = study.transactions.where(payment_type: "Participant study reward", receiver_id: @current_user.id).first
        if transaction.present?
          paid_amount +=  transaction.try(:amount)
          transaction_count +=1
        end
      end
      monthly_payment.push(sprintf('%.2f', paid_amount))
      monthly_transaction.push(transaction_count)
      total_transaction += transaction_count
      
      end_time = start_time
      start_time = start_time-1.month

      i += 1
      if i == 12
        break       
      end
    end
    month = FunctionService.month_array



    eligible_candidates.each do |eligible_candidate|
      study = eligible_candidate.study
      transaction = study.transactions.where(payment_type: "Participant study reward", receiver_id: @current_user.id).first
      transactions.push(study: study,transaction: transaction)
    end
    render json: {Data: {transactions: transactions, total_payment: sprintf('%.2f', total_payment), total_transaction: total_transaction, monthly_payment: monthly_payment.reverse,
      monthly_transaction: monthly_transaction.reverse, month: month}, CanEdit: false, CanDelete: false, Status: :ok, message: "participant-transactions", Token: nil, Success: false}, status: :ok
  end
  private
    def set_transaction
      @transaction = Transaction.find(params[:id])
    end

    def transaction_params
      params.fetch(:transaction, {})
    end
end
